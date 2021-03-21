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
    @posts = Post.includes(:user).where(user_id: @user.id).order(created_at: :desc).limit(3)
    @post_comments = PostComment.includes(:user, :post).where(user_id: @user.id).order(created_at: :desc).limit(3)
  end

  # ユーザー凍結処理
  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    if @user.is_active
      redirect_to admin_user_path(@user), notice: 'アカウントの凍結を解除しました。'
      SuspendMailer.unsuspend_mail(@user).deliver_now
    else
      redirect_to admin_user_path(@user), notice: 'アカウントを凍結しました。'
      SuspendMailer.suspend_mail(@user).deliver_now
    end
  end

  private
    def user_params
      params.require(:user).permit(:is_active)
    end
end
