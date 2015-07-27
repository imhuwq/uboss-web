class AdminController < ApplicationController
  layout 'admin'

  if Rails.env.production? || Rails.env.staging?
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.json { render nothing: true, status: :forbidden }
        format.html { redirect_to admin_root_url, alert: '您无权访问该资源。' }
      end
    end
  end

  def super_admin?
    if current_user.user_roles.collect(&:name).include?('super_admin')
      return true
    else
      return false
    end
  end


end
