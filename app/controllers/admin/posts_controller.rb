class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!

  def index
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @posts = Post.where(user_id: @user.id).reverse_order.page(params[:page])
    else
      @posts = Post.all.reverse_order.page(params[:page])
    end
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
