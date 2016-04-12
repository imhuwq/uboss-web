class CallingNotifiesController < ApplicationController
  before_action :authenticate_user!
  layout 'calling_services'

  def index
    @calling_notifies = current_user.calling_notifies.order("called_at DESC")
  end

  def change_status
    @calling_notify = CallingNotify.find_by(user: current_user, id: params[:id])

    if @calling_notify.update(status: 'serviced')
      render json: { status: "ok", id: @calling_notify.id }
    else
      render json: { status: "failure", error_msg: @calling_notify.errors.full_messages.join('<br>') }
    end
  end
end
