class Public::RelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = User.find(params[:user_id])
    current_user.follow(@user)
    if @user.follow_notice == true
      @user.create_notification_follow(current_user)
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    current_user.unfollow(@user)
  end
end
