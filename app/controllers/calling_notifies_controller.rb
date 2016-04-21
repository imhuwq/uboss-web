class CallingNotifiesController < ApplicationController

  realtime_controller({queue: :redis})

  before_action :authenticate_user!
  before_action :find_current_account
  layout 'calling_services'

  def index
    @calling_notifies = @current_account.calling_notifies.order("called_at DESC")
  end

  def change_status
    @calling_notify = @current_account.calling_notifies.find(params[:id])

    if @calling_notify.update(status: 'serviced')
      @calling_notify.delay.send_weixin_text_custom_to_user
      checkout = @calling_notify.service_name == "结帐"
      render json: { status: "ok", id: @calling_notify.id, checkout: checkout, number: @calling_notify.calling_number }
    else
      render json: { status: "failure", error_msg: @calling_notify.errors.full_messages.join('<br>') }
    end
  end

  def switching_account
    if !current_user.has_store_account?
      flash[:error] = '您没有子账号'
      redirect_to action: :index
    else
      @store_accounts = current_user.store_accounts.active.includes(user: :service_store)
    end
  end

  def switch_account
    if params[:sid].nil?
      session[:store_account_id] = nil
      flash[:success] = "退出成功"
    elsif current_user.store_accounts.active.find_by(user_id: params[:sid]).try(:user)
      session[:store_account_id] = params[:sid]
      flash[:success] = "切换成功"
    else
      flash[:error] = "切换失败"
    end
    redirect_to action: :index
  end

  private

  def find_current_account
    if session[:store_account_id].present?
      @current_account = current_user.store_accounts.active.find_by(user_id: session[:store_account_id]).try(:user)
    end
    @current_account ||= current_user
  end

end
