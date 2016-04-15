class CallingNotifiesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_current_account
  layout 'calling_services'

  def index
    @calling_notifies = @current_account.calling_notifies.order("called_at DESC")
  end

  def change_status
    @calling_notify = @current_account.calling_notifies.find(params[:id])

    if @calling_notify.serviced?
      render json: { status: "ok", id: @calling_notify.id, msg: '已服务, 无需重复服务' }
      return
    end

    if @calling_notify.update(status: 'serviced')
      if @calling_notify.service_name == "结帐"
        TableNumber.clear_seller_table_number(@current_account, @calling_notify.calling_number)
        flash_msg = "结帐后自动下桌（#{@calling_notify.calling_number}号桌）"
        checkout = true
      else
        flash_msg = "去服务吧^_^"
        checkout = false
      end

      trigger_realtime_message(change_status_notify_msg(checkout), [@current_account.id])
      render json: { status: "ok", id: @calling_notify.id, checkout: checkout, number: @calling_notify.calling_number, msg: flash_msg }
    else
      render json: { status: "failure", error_msg: @calling_notify.errors.full_messages.join('<br>') }
    end
  end

  def switching_account
    if !current_user.has_store_account?
      flash[:error] = '你没有子账号'
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

  def change_status_notify_msg(checkout)
    {
      type: 'change_status',
      calling_notify_id: @calling_notify.id,
      calling_number: @calling_notify.calling_number,
      checkout: checkout
    }
  end

  def find_current_account
    if session[:store_account_id].present?
      @current_account = current_user.store_accounts.active.find_by(user_id: session[:store_account_id]).try(:user)
    end
    @current_account ||= current_user
  end
end
