class Public::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id).page(params[:page]).reverse_order
  end

  def index
    @users = User.all
    if params[:word].present?
      @users = @users.search_for(params[:word])
      @word = params[:word]
    end
    @users = @users.page(params[:page]).reverse_order
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
    # フォローしているユーザー＋自分の投稿を最新順で取得
    users = current_user.following
    @posts = []
    if users.present?
      users.each do |user|
      following_user_posts = Post.where(user_id: user.id)
      @posts.concat(following_user_posts)
      end
      current_user_posts = Post.where(user_id: current_user.id)
      @posts.concat(current_user_posts)
      @posts = @posts.sort_by!{|post| post.created_at}.reverse!
    else
      @posts = current_user.posts.reverse_order.page(params[:page])
    end
    # タイムライン内検索
    if params[:body].present?
      @posts = @posts.select do |post|
        post.body.include?(params[:body])
      end
      @word = params[:body]
    end
    if params[:category].present?
      if params[:category] == '川柳'
        @posts = @posts.select do |post|
          post.category == 'senryu'
        end
      elsif params[:category] == '短歌'
        @posts = @posts.select do |post|
          post.category == 'tanka'
        end
      else
        @posts = @posts.select do |post|
          post.category == 'free_haiku'
        end
      end
      @category = params[:category]
    end
    @posts = Kaminari.paginate_array(@posts).page(params[:page])
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
