class Admin::InformationController < ApplicationController
  before_action :authenticate_admin!

  def new
    session.delete(:information)
    @information = Information.new
  end

  def back
    @information = Information.find_or_initialize_by(session[:information])
    if @information.id.blank?
      render :new
    else
      render :edit
    end
  end

  def confirm
    @information = Information.find_or_initialize_by(info_params)
    session[:information] = @information
    if @information.invalid?
      if @information.id.blank?
        render :new
      else
        render :edit
      end
    end
  end

  def create
    @information = Information.create!(session[:information])
    redirect_to admin_information_path(@information), notice: '新しいお知らせを投稿しました。'
    session.delete(:information)
  end

  def show
    @information = Information.find(params[:id])
  end

  def index
    @information = Information.page(params[:page]).order(created_at: :desc)
  end

  def edit
    session.delete(:information)
    @information = Information.find(params[:id])
  end

  def update
    session[:information].delete('created_at')
    session[:information].delete('updated_at')
    @information = Information.find(params[:id])
    @information.update(session[:information])
    redirect_to admin_information_path(@information), notice: 'お知らせを更新しました。'
    session.delete(:information)
  end

  def destroy
    information = Information.find(params[:id])
    information.destroy
    redirect_to admin_information_index_path
  end

  private

  def info_params
    params.require(:information).permit(:id, :title, :body)
  end
end
