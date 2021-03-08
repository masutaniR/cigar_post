class Public::PostCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:destroy]

  def create
    @new_comment = PostComment.new
    @post = Post.find(params[:post_id])
    @post_comment = current_user.post_comments.new(post_comment_params)
    @post_comment.post_id = @post.id
    if @post_comment.save
      @post.create_notification_comment(current_user, @post_comment.id)
    else
      render 'error'
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    PostComment.find_by(id: params[:id], post_id: @post.id).destroy
    @post_comment = PostComment.new
  end

  private
    def post_comment_params
      params.require(:post_comment).permit(:comment, :category)
    end

    def ensure_correct_user
      @post_comment = PostComment.find(params[:id])
      unless @post_comment.user == current_user
        redirect_to user_path(current_user)
      end
    end
end
