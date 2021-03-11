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
    get 'information/new/confirm' => 'information#confirm'
    get 'information/edit/confirm' => 'information#confirm'
    # get 'information/confirm' => 'information#confirm'
    get 'information/new/back' => 'information#back'
    get 'information/edit/back' => 'information#back'
    # get 'information/back' => 'information#redirect'
  end

  devise_for :users, controllers: {
    sessions: 'public/sessions',
    registrations: 'public/registrations',
    passwords: 'public/passwords'
  }

  devise_scope :user do
    post 'users/guest_sign_in' => 'public/sessions#new_guest'
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

  # 開発環境で送信したメールを /letter_opener で確認する
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
