class Admin::CallingNotifiesController < AdminController
  load_and_authorize_resource

  def index
    @table_numbers = TableNumber.where(user: current_user).order('number ASC')
    @calling_notifies = @calling_notifies.order('called_at DESC')
      .includes(:table_number, :calling_service)
      .page(params[:page] || 1)
    @unservice_count = @calling_notifies.unservice.count
    flash[:success] = "您有#{@unservice_count}条呼叫服务未处理" if @unservice_count > 0
  end

end
