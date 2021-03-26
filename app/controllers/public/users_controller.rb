class Public::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id).includes(:user, :post_comments, :likes).page(params[:page]).order(created_at: :desc)
  end

  def index
    @users = User.all
    @word = params[:word]
    # キーワード検索
    @users = @users.search_for(@word) if params[:word].present?
    # 並び替え
    @users = @users.sort_for(params[:sort]) || @users.order(created_at: :desc)
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
  def withdraw_confirm; end

  # いいね一覧
  def likes
    @user = User.find(params[:id])
    @posts = Kaminari.paginate_array(@user.likes.includes(post: [:post_comments, :likes, :user])
             .order(created_at: :desc).map{ |like| like.post }).page(params[:page])
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
    users = current_user.following.includes(posts: [:post_comments, :likes])
    @posts = []
    users.each do |user|
      following_user_posts = user.posts
      @posts.concat(following_user_posts)
    end
    current_user_posts = Post.where(user_id: current_user.id).includes(:user, :post_comments, :likes)
    @posts.concat(current_user_posts)
    @posts = @posts.sort_by{ |post| post.created_at }.reverse
    # キーワード検索
    if params[:body].present?
      @body = params[:body]
      @posts = @posts.select do |post|
        post.body.include?(@body)
      end
    end
    # カテゴリ検索
    if params[:category].present?
      @posts = @posts.select do |post|
        post.category == params[:category]
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
