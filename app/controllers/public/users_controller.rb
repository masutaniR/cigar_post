class Public::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id).page(params[:page]).order(created_at: :desc)
  end

  def index
    @users = User.all
    # キーワード検索
    if params[:word].present?
      @word = params[:word]
      @users = @users.search_for(@word)
    end
    # 並び替え
    if params[:sort].present?
      @users = @users.sort_for(params[:sort])
    else
      @users = @users.order(created_at: :desc)
    end
    @users = @users.page(params[:page])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.email == 'test@test.com'
      redirect_to request.referer, alert: 'ゲストアカウントは編集できません。'
    elsif @user.update(user_params)
      redirect_to user_path(@user), notice: 'ユーザー情報が更新されました。'
    else
      render :edit
    end
  end

  # 退会確認
  def withdraw_confirm
  end

  # いいね一覧
  def likes
    @user = User.find(params[:id])
    @posts = Kaminari.paginate_array(@user.likes.order(created_at: :desc).map{|like| like.post}).page(params[:page])
  end

  # フォロー一覧
  def following
    @user = User.find(params[:id])
    @users = @user.following.page(params[:page]).order(created_at: :desc)
  end

  # フォロワー一覧
  def followers
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page]).order(created_at: :desc)
  end

  # タイムライン
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
      @posts = current_user.posts.order(created_at: :desc).page(params[:page])
    end
    # タイムライン内検索
    if params[:body].present?
      @body = params[:body]
      @posts = @posts.select do |post|
        post.body.include?(@body)
      end
    end
    if params[:category].present?
      case params[:category]
      when 'senryu'
        @posts = @posts.select do |post|
          post.category == 'senryu'
        end
      when 'tanka'
        @posts = @posts.select do |post|
          post.category == 'tanka'
        end
      when 'free_haiku'
        @posts = @posts.select do |post|
          post.category == 'free_haiku'
        end
      end
    end
    @posts = Kaminari.paginate_array(@posts).page(params[:page])
  end

  private
    def user_params
      params.require(:user).permit(
        :name, :introduction, :profile_image, :like_notice, :comment_notice, :other_comment_notice, :follow_notice
        )
    end

    def ensure_correct_user
      @user = User.find(params[:id])
      unless @user == current_user
        redirect_to user_path(current_user)
      end
    end
end
