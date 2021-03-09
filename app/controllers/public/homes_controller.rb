class Public::HomesController < ApplicationController
  def top
    @popular_posts = Post.find(Like.group(:post_id).order('count(post_id) DESC').limit(3).pluck(:post_id))
    @new_posts = Post.all.reverse_order.limit(3)
    @information = Information.all.reverse_order.limit(3)
  end

  def about
  end
end
