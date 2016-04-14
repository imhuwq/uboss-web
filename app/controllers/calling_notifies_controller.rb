class CallingNotifiesController < ApplicationController
  before_action :authenticate_user!
  layout 'calling_services'

  def index
    @calling_notifies = current_user.calling_notifies.order("called_at DESC")
  end

  def change_status
    @calling_notify = current_user.calling_notifies.find(params[:id])

    if @calling_notify.serviced?
      render json: { status: "ok", id: @calling_notify.id, msg: '已服务, 无需重复服务' }
      return
    end

    if @calling_notify.update(status: 'serviced')
      if @calling_notify.service_name == "结帐"
        TableNumber.clear_seller_table_number(current_user, @calling_notify.calling_number)
        flash_msg = "结帐后自动下桌（#{@calling_notify.calling_number}号桌）"
        checkout = true
      else
        flash_msg = "去服务吧^_^"
        checkout = false
      end

      trigger_realtime_message(change_status_notify_msg(checkout), [current_user.id])
      render json: { status: "ok", id: @calling_notify.id, checkout: checkout, number: @calling_notify.calling_number, msg: flash_msg }
    else
      render json: { status: "failure", error_msg: @calling_notify.errors.full_messages.join('<br>') }
    end
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
end
