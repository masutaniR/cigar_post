# frozen_string_literal: true

class Public::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end
  def after_sign_up_path_for(resource)
    user_path(current_user)
  end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    if current_user.email == 'test@test.com'
      redirect_to edit_user_registration_path, alert: 'ゲストアカウントは編集できません。'
    elsif current_user.uid.present?
      redirect_to edit_user_registration_path, alert: 'Googleアカウントは編集できません。'
    else
      super
    end
  end

  def after_update_path_for(resource)
    user_path(current_user)
  end

  # DELETE /resource
  def destroy
    @user = current_user
    if @user.email == 'test@test.com'
      redirect_to edit_user_registration_path, alert: 'ゲストアカウントは退会できません。'
    # Googleアカウント以外は退会時パスワードを要求
    elsif @user.uid.present? || @user.valid_password?(params[:password])
      @user.destroy
      redirect_to root_path, notice: '退会手続が完了しました。ご利用ありがとうございました。'
    else
      redirect_to edit_user_registration_path, alert: 'パスワードが違います。'
    end
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :profile_image, :introduction])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
