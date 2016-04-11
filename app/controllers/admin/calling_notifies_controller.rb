class Admin::CallingNotifiesController < AdminController
  load_and_authorize_resource

  def index
    @table_numbers = TableNumber.where(user: current_user).order('number ASC')
    @calling_notifies = @calling_notifies.order('called_at DESC')
      .includes(:table_number, :calling_service)
      .page(params[:page] || 1)
    @unservice_count = @calling_notifies.unservice.count
    @notice = "您有#{@unservice_count}条呼叫服务未处理" if @unservice_count > 0
  end

  def change_status
    if params[:status] == 'serviced'
      @calling_notify.status = "serviced"
      flash.now[:success] = "已服务"
    end

    unless @calling_notify.save
      @error = model_errors(@calling_notify).join('<br/>')
    end

    if request.xhr?
      render(partial: 'calling_notifies', locals: { calling_notifies: [@calling_notify.reload] })
    else
      redirect_to action: :index
    end
  end

  def drop_table
    @table_number = TableNumber.find_by(user: current_user, number: params[:number], status: 1)

    if @table_number && TableNumber.clear_seller_table_number(current_user, params[:number])
      render json: { status: 'ok', number: @table_number.number }
    else
      render json: { status: 'no_found' }
    end
  end

end
