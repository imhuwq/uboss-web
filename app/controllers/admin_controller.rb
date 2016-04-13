class AdminController < ApplicationController

  include OperationLoggable
  include SessionsHelper

  layout 'admin'

  before_action :check_current_account_availability, if: -> { session[:sub_account_id].present? }

  if not Rails.env.development?
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.json { render nothing: true, status: :forbidden }
        format.html { redirect_to admin_root_url, alert: '您无权访问该资源。' }
      end
    end
  end

  realtime_controller({:queue => :redis})

  private

  def check_current_account_availability
    if !original_current_user.store_accounts.active.where(user_id: session[:sub_account_id]).exists?
      flash[:error] = '子账号失效'
      set_current_account(nil)
      redirect_to admin_root_path
    end
  end

  alias original_current_user current_user
  def current_user
    if current_account.present?
      current_account
    else
      super
    end
  end

  def current_account
    return @current_account if @current_account.present?
    return nil if session[:sub_account_id].blank?
    @current_account = original_current_user.store_accounts.
      active.find_by(user_id: session[:sub_account_id]).try(:user)
    return nil if @current_account.blank?
    @current_account.being_agency = true
    @current_account
  end
  helper_method :current_account

  def set_current_account(account)
    return nil if !original_current_user.has_store_account?
    if account.nil?
      session[:sub_account_id] = nil
      @current_account = nil
      return nil
    end
    account = account.is_a?(User) ? account : User.find_by(id: account)
    return nil if account.blank?
    session[:sub_account_id] = account.id
    @current_account = original_current_user.store_accounts.
      active.find_by(user_id: session[:sub_account_id]).try(:user)
    return nil if @current_account.blank?
    @current_account.being_agency = true
    @current_account
  end

  def current_navigation_context
    if current_account.present?
      'sub_account'
    else
      :default
    end
  end
  helper_method :current_navigation_context

  def realtime_user_id
    (current_user && current_user.id) || 1
  end

  def realtime_server_url
    Rails.application.secrets.realtime_server_url
  end

  def check_new_supplier
    if current_user.is_supplier?
      unless current_user.supplier_store.phone_number.present?
        redirect_to edit_info_admin_supplier_store_path, notice: '请先完善客服信息'
      end
    else
      redirect_to new_admin_supplier_store_path, notice: '请先创建供货店铺'
    end
  end

  def find_or_create_express
    @express = Express.find_by_name(params[:express_name])
    @express = Express.create(name: params[:express_name], private_id: current_user.id) if @express.blank?
    @express
  end

end
