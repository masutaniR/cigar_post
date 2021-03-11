class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @users = User.all
    # キーワード検索
    if params[:word].present?
      @word = params[:word]
      @users = @users.admin_search_for(@word)
    end
    @users = @users.page(params[:page]).order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id).order(created_at: :desc).limit(3)
    @post_comments = PostComment.where(user_id: @user.id).order(created_at: :desc).limit(3)
  end
end
