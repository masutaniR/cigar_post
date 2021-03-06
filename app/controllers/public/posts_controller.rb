class Public::PostsController < ApplicationController
  before_action :authenticate_user!
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
  end
  
  def index
  end
  
  def destroy
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
