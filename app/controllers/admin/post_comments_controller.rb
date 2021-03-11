class Admin::PostCommentsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @post_comments = PostComment.all
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @post_comments = @post_comments.where(user_id: @user.id).reverse_order.page(params[:page])
    end
    if params[:comment].present?
      @comment = params[:comment]
      @post_comments = @post_comments.comment_search_for(@comment)
    end
    if params[:category].present?
      @post_comments = @post_comments.category_search_for(params[:category])
    end
    @post_comments = @post_comments.page(params[:page]).order(created_at: :desc)
  end

  def destroy
    @post = Post.find(params[:post_id])
    PostComment.find_by(id: params[:id], post_id: @post.id).destroy
    @post_comment = PostComment.new
  end
end
