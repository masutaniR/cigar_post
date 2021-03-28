class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

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

  def render_404
    render 'errors/error_404', status: 404
  end
end
