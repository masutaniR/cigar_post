# frozen_string_literal: true

class Public::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  before_action :reject_inactive_user, only: [:create]

  def new_guest
    user = User.guest
    sign_in user
    redirect_to timeline_path, notice: 'ゲストアカウントでログインしました。'
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # 凍結されているアカウントをブロック
  def reject_inactive_user
    @user = User.find_by(email: params[:user][:email])
    if @user
      if (@user.valid_password?(params[:user][:password])) && (@user.is_active == false)
        redirect_to new_user_session_path, alert: 'アカウントが凍結されています。'
      end
    end
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
