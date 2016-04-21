class Admin::CallingNotifiesController < AdminController

  load_and_authorize_resource
  realtime_controller({queue: :redis})

  before_action :validate_service_store_info, only: [:index]

  def index
    @table_numbers = TableNumber.where(user: current_user).order('number ASC')
    if @table_numbers.blank?
      flash[:alert] = "请先完善服务设置"
      redirect_to set_table_info_admin_calling_services_path
      return
    end

    @calling_notifies = @calling_notifies.order('called_at DESC')
      .includes(:table_number, :calling_service)
      .page(params[:page] || 1)
    @unservice_count = @calling_notifies.unservice.count
    @notice = "您有#{@unservice_count}条呼叫服务未处理" if @unservice_count > 0
  end

  def change_status
    if params[:status] == 'serviced'
      @calling_notify.status = "serviced"
    end

    if @calling_notify.save
      @calling_notify.delay.send_weixin_text_custom_to_user if params[:notice] != "false"
      flash.now[:success] = "已服务"
      calling_notifies = @calling_notify.service_name == "结帐" ? [] : [@calling_notify.reload]
    else
      flash.now[:error] = model_errors(@calling_notify).join('<br/>')
      calling_notifies = [@calling_notify]
    end

    if request.xhr?
      render(partial: 'calling_notifies', locals: { calling_notifies: calling_notifies })
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

  private

  def validate_service_store_info
    unless current_user.service_store.try(:valid?)
      flash[:alert] = '请先完善实体店铺信息'
      redirect_to edit_admin_service_store_path(current_user.service_store)
    end
  end
end
