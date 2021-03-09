class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @users = User.all
    if params[:word].present?
      @users = @users.admin_search_for(params[:word])
      @word = params[:word]
    end
    @users = @users.page(params[:page]).reverse_order
  end

  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id).limit(3)
    @post_comments = PostComment.where(user_id: @user.id).reverse_order.limit(3)
  end
end
