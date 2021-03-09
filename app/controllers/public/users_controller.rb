class Public::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id).page(params[:page]).reverse_order
  end

  def index
    @users = User.page(params[:page])
    if params[:name].present?
      @users = @users.search_for(params[:name])
      @name = params[:name]
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.email == 'test@test.com'
      redirect_to edit_user_path(@user), alert: 'ゲストアカウントは編集できません。'
    elsif @user.update(user_params)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def withdraw_confirm
  end

  def likes
    @user = User.find(params[:id])
    @posts = Kaminari.paginate_array(@user.likes.reverse_order.map{|like| like.post}).page(params[:page])
  end

  def following
    @user = User.find(params[:id])
    @users = @user.following.page(params[:page]).reverse_order
  end

  def followers
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page]).reverse_order
  end

  def home
    users = current_user.following
    @posts = []
    if users.present?
      users.each do |user|
      following_user_posts = Post.where(user_id: user.id)
      @posts.concat(following_user_posts)
      end
      current_user_posts = Post.where(user_id: current_user.id)
      @posts.concat(current_user_posts)
      @posts = Kaminari.paginate_array(@posts.sort_by!{|post| post.created_at}.reverse!).page(params[:page])
    else
      @posts = current_user.posts.reverse_order.page(params[:page])
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :introduction, :profile_image)
    end

    def ensure_correct_user
      @user = User.find(params[:id])
      unless @user == current_user
        redirect_to user_path(current_user)
      end
    end
end
