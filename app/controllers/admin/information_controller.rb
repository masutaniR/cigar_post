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
    @information = Information.find(params[:id])
  end

  def update
    @information = Information.find(params[:id])
    if @information.update(info_params)
      redirect_to admin_information_path(@information)
    else
      render :edit
    end
  end

  def destroy
    information = Information.find(params[:id])
    information.destroy
    redirect_to admin_information_index_path
  end

  private
    def info_params
      params.require(:information).permit(:title, :body)
    end
end
