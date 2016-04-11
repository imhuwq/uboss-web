class CallingServicesController < ApplicationController
  before_action :authenticate_user!, only: [:store_notifies]
  before_action :find_seller
  before_action :find_unuse_table_numbers, only: [:table_numbers, :set_table_number]
  before_action :find_using_table_number,  only: [:index, :notifies, :calling]

  def index
    @calling_services = @seller.calling_services
  end

  def notifies
    @calling_notifies = CallingNotify.where(user: @seller, table_number: @table_number)
  end

  def calling
    @calling_service = if params[:service_id].present?
                        CallingService.find_by(user: @seller, id: params[:service_id])
                      elsif params[:type] == "checkout"
                        CallingService.find_or_create_by(user: @seller, name: "结帐")
                      elsif params[:type] == "other"
                        CallingService.find_or_create_by(user: @seller, name: "其它")
                      end

    @calling_notify = CallingNotify.find_or_initialize_by(user: @seller, table_number: @table_number, calling_service: @calling_service)

    unless @calling_notify.new_record?
      @calling_notify.called_at = Time.now
      @calling_notify.status = 'unservice'
    end

    if @calling_notify.save
      trigger_realtime_message
      notify_seller
      render json: { status: "ok", message: "呼叫成功" }
    else
      render json: { status: "failure", error: "呼叫错误，请刷新再尝试" }
    end
  end

  def table_numbers
    @select_arr = @table_numbers.pluck(:number, :id)
  end

  def set_table_number
    table_number = @table_numbers.find_by(id: params[:table_number][:id])

    if table_number
      TableNumber.clear_seller_table_number(@seller, cookies[:table_nu])
      cookies[:table_nu] = table_number.number
      table_number.update(status: 1)
      redirect_to action: :index
    else
      flash[:error] = "请选择正确的桌号"
      redirect_to action: :table_numbers
    end
  end

  def store_notifies
    @calling_notifies = @seller.calling_notifies
  end

  private
  def trigger_realtime_message
    $redis.publish 'realtime_msg', {msg: {text: "#{@table_number.number}号桌需要#{@calling_service.name}", title: '新服务通知'}, recipient_user_ids: [@seller.id]}.to_json
  end

  def notify_seller
    if @seller.weixin_openid.present?
      $weixin_client.send_text_custom(
        @seller.weixin_openid,
        <<-MSG
服务提醒：
#{@table_number.number}号桌需要#{@calling_service.name}
---------
<a href='#{notifies_seller_calling_services_url(seller_id: @seller.id)}'>查看详情</a>
        MSG
      )
    end
  end

  def find_seller
    @seller = User.find(params[:seller_id])
  end

  def find_unuse_table_numbers
    @table_numbers = TableNumber.where(user: @seller, status: 0)
  end

  def find_using_table_number
    unless @table_number = TableNumber.find_by(user: @seller, number: cookies[:table_nu], status: 1)
      redirect_to action: :table_numbers
    end
  end
end
