class Public::PostCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:destroy]

  def create
    @new_comment = PostComment.new
    @post = Post.find(params[:post_id])
    @post_comments = @post.post_comments.includes(:user)
    @post_comment = current_user.post_comments.new(post_comment_params)
    @post_comment.post_id = @post.id
    if @post_comment.save
      # コメント通知を許可している場合のみポスト投稿者へ通知
      if @post.user.comment_notice
        @post.create_notification_comment(current_user, @post_comment.id, @post.user.id)
      end
      # コメントした投稿への他のコメント投稿通知を許可している場合のみ他のコメント投稿者へ通知
      temp_ids = PostComment.select(:user_id).where(post_id: @post.id)
                 .where.not("(user_id = ?) OR (user_id = ?)", current_user.id, @post.user.id).distinct
      temp_ids.each do |temp_id|
        comment_user = User.find(temp_id['user_id'])
        if comment_user.other_comment_notice
          @post.create_notification_comment(current_user, @post_comment.id, comment_user.id)
        end
      end
    else
      render 'error'
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post_comments = @post.post_comments.includes(:user)
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
