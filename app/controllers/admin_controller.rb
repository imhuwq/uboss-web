class AdminController < ApplicationController

  include SessionsHelper

  before_action :set_password, if: ->{ request.get? && current_user.need_reset_password? }

  layout 'admin'

  if not Rails.env.development?
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.json { render nothing: true, status: :forbidden }
        format.html { redirect_to admin_root_url, alert: '您无权访问该资源。' }
      end
    end
  end

  protected

  def set_password
    flash[:notice] = '继续操作前请设置您的登录密码'
    flash[:new_password_enabled] = true
    store_location_for(current_user, request.fullpath)
    redirect_to set_password_path
  end

end
