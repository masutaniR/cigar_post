class Public::InformationController < ApplicationController
  def show
    @information = Information.find(params[:id])
  end

  def index
    @information = Information.page(params[:page]).reverse_order
  end
end
