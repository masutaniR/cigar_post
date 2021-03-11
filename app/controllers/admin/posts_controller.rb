class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @posts = Post.all
    # ユーザーごとの投稿一覧
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @posts = Post.where(user_id: @user.id).page(params[:page])
    end
    # キーワード検索
    if params[:body].present?
      @body = params[:body]
      @posts = @posts.body_search_for(@body)
    end
    # カテゴリー検索
    if params[:category].present?
      @posts = @posts.category_search_for(params[:category])
    end
    @posts = @posts.page(params[:page]).order(created_at: :desc)
  end

  def show
    @post = Post.find(params[:id])
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to admin_posts_path
  end
end
