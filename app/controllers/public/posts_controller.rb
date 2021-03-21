class Public::PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :ensure_correct_user, only: [:destroy]

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    if @post.save
      redirect_to post_path(@post)
    else
      render :new
    end
  end

  def show
    @post = Post.find(params[:id])
    @post_comments = @post.post_comments.includes(:user)
    @post_comment = PostComment.new
  end

  def index
    @posts = Post.all.includes(:user, :post_comments, :likes)
    # キーワード検索
    if params[:body].present?
      @body = params[:body]
      @posts = @posts.body_search_for(@body)
    end
    # カテゴリー検索
    if params[:category].present?
      @posts = @posts.category_search_for(params[:category])
    end
    # 並び替え
    @posts = if params[:sort].present?
               @posts.sort_for(params[:sort])
             else
               @posts.order(created_at: :desc)
             end
    @posts = @posts.page(params[:page])
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to user_path(current_user)
  end

  private

  def post_params
    params.require(:post).permit(:body, :post_image, :category)
  end

  def ensure_correct_user
    @post = Post.find(params[:id])
    unless @post.user == current_user
      redirect_to user_path(current_user)
    end
  end
end
