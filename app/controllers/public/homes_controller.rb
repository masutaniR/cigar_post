class Public::HomesController < ApplicationController
  def top
    @new_posts = Post.all.reverse_order.limit(3)
    @information = Information.all.reverse_order.limit(3)
  end

  def about
  end
end
