class Public::HomesController < ApplicationController
  def top
    @information = Information.all.reverse_order.limit(3)
  end

  def about
  end
end
