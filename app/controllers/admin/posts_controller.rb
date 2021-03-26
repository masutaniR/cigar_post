class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @posts = Post.all.includes(:user)
    @body = params[:body]
    # ユーザーごとの投稿一覧
    if params[:user_id]
      @user = User.find(params[:user_id])
      @posts = @posts.where(user_id: @user.id)
    end
    # キーワード検索
    @posts = @posts.body_search_for(@body) if params[:body].present?
    # カテゴリー検索
    @posts = @posts.category_search_for(params[:category]) if params[:category].present?
    @posts = @posts.page(params[:page]).order(created_at: :desc)
  end

  def show
    @post = Post.find(params[:id])
    @post_comments = @post.post_comments.includes(:user)
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to admin_posts_path
  end
end
