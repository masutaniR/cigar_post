class Admin::PostCommentsController < ApplicationController
  before_action :authenticate_admin!

  def index
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @post_comments = PostComment.where(user_id: @user.id).reverse_order.page(params[:page])
    else
      @post_comments = PostComment.all.reverse_order.page(params[:page])
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    PostComment.find_by(id: params[:id], post_id: @post.id).destroy
    @post_comment = PostComment.new
  end
end
