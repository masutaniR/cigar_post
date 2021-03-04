class ApplicationController < ActionController::Base
  def after_sign_up_path_for(resource)
    root_path
  end

  def after_sign_in_path_for(resource)
      case resource
      when Admin
        root_path
      when User
        root_url
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
