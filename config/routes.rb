Rails.application.routes.draw do
  devise_for :admin, :skip => [:registrations, :password], controllers: {
    sessions: 'admin/sessions',
  }

  namespace :admin do
    resources :users, only: [:index, :show]
    resources :posts, only: [:index, :show, :destroy] do
      resources :post_comments, only: [:destroy]
    end
    resources :post_comments, only: [:index]
    resources :information
  end

  devise_for :users, controllers: {
    sessions: 'public/sessions',
    registrations: 'public/registrations',
    passwords: 'public/passwords'
  }

  devise_scope :user do
    post 'users/guest_sign_in', to: 'public/sessions#new_guest'
  end

  scope module: :public do
    root 'homes#top'
    get 'about' => 'homes#about'
    get 'home' => 'users#home', as: 'timeline'
    resources :information, only: [:index, :show]
    resources :users, only: [:index, :show, :edit, :update] do
      resource :relationships, only: [:create, :destroy]
      member do
        get :following, :followers, :likes
      end
      collection do
        get :withdraw_confirm
      end
    end
    resources :posts, only: [:new, :create, :show, :index, :destroy] do
      resources :post_comments, only: [:create, :destroy]
      resource :likes, only: [:create, :destroy]
    end
    resources :notifications, only: [:index]
  end
end
