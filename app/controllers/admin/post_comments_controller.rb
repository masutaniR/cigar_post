class Admin::PostCommentsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @post_comments = PostComment.all.includes(:user, :post)
    @comment = params[:comment]
    # ユーザーごとのコメント一覧
    if params[:user_id]
      @user = User.find(params[:user_id])
      @post_comments = @post_comments.where(user_id: @user.id)
    end
    # キーワード検索
    @post_comments = @post_comments.comment_search_for(@comment) if params[:comment].present?
    # カテゴリ検索
    @post_comments = @post_comments.category_search_for(params[:category]) if params[:category].present?
    @post_comments = @post_comments.page(params[:page]).order(created_at: :desc)
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post_comments = @post.post_comments.includes(:user)
    PostComment.find_by(id: params[:id], post_id: @post.id).destroy
  end
end
