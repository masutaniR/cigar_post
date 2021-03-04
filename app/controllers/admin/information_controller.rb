class Admin::InformationController < ApplicationController
  before_action :authenticate_admin!

  def new
    @information = Information.new
  end

  def create
    @information = Information.new(info_params)
    if @information.save
      redirect_to admin_information_path(@information)
    else
      render :new
    end
  end

  def show
    @information = Information.find(params[:id])
  end

  def index
    @information = Information.page(params[:page]).per(10).reverse_order
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
    def info_params
      params.require(:information).permit(:title, :body)
    end
end
