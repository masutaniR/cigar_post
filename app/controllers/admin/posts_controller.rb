class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @posts = Post.all
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @posts = Post.where(user_id: @user.id).page(params[:page])
    end
    if params[:body].present?
      @posts = @posts.body_search_for(params[:body])
      @word = params[:body]
    end
    if params[:category].present?
      @posts = @posts.category_search_for(params[:category])
      @category = params[:category]
    end
    @posts = @posts.page(params[:page])
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
