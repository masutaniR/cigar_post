class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
      case resource
      when Admin
        admin_users_path
      when User
        timeline_path
      end
  end

  def after_sign_out_path_for(resource)
    if resource == :admin
      new_admin_session_path
    else
      root_url
    end
  end
end
