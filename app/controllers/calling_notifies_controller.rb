class CallingNotifiesController < ApplicationController
  before_action :authenticate_user!
  layout 'calling_services'

  def index
    @calling_notifies = current_user.calling_notifies.order("called_at DESC")
  end

  def change_status
    @calling_notify = CallingNotify.find_by(user: current_user, id: params[:id])

    if @calling_notify.update(status: 'serviced')
      trigger_realtime_message(change_status_notify_msg, [current_user.id])
      render json: { status: "ok", id: @calling_notify.id }
    else
      render json: { status: "failure", error_msg: @calling_notify.errors.full_messages.join('<br>') }
    end
  end

  private

  def change_status_notify_msg
    {
      type: 'change_status',
      calling_notify_id: @calling_notify.id
    }
  end

end
