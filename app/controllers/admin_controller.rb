class AdminController < ApplicationController

  include OperationLoggable
  include SessionsHelper

  layout 'admin'

  if not Rails.env.development?
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.json { render nothing: true, status: :forbidden }
        format.html { redirect_to admin_root_url, alert: '您无权访问该资源。' }
      end
    end
  end

  private

  def check_new_supplier
    if current_user.is_supplier?
      unless current_user.supplier_store.phone_number.present?
        redirect_to edit_info_admin_supplier_stores_path, notice: '请先完善客服信息'
      end
    else
      redirect_to new_admin_supplier_stores_path, notice: '请先创建供货店铺'
    end
  end

end
