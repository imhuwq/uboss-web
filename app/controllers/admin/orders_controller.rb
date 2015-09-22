class Admin::OrdersController < AdminController
  load_and_authorize_resource

  before_filter :validate_express_params, only: :set_express

  # TODO record use operations
  after_action :record_operation, only: [:update]

  def select_orders
    @orders = Order.where(id: params[:ids])
  end

  def batch_shipments
    success, errors = 0, 0
    if params[:order].present?
      params[:order].each do |order_id, param|
        order = Order.find(order_id)
        express = Express.find_or_create_by(name: param[:express_name])
        if validate_batch_shipment_params(param) \
          && order.update({ship_number: param[:ship_number], express: express}) \
          && order.ship!
          success += 1
        else
          errors += 1
        end
      end
    end

    if errors != 0
      flash[:error] = "批量发货 #{errors} 个订单发货失败"
    else
      flash[:success] = "所有订单发货成功"
    end
    redirect_to admin_orders_path
  end

  def index
    @orders = @orders.recent.includes(:user).page(param_page)
    @unship_amount = @orders.payed.total_count
    @today_selled_amount = @orders.today.selled.total_count
    @shiped_amount = @orders.shiped.total_count
  end

  def show
    @order_item = @order.order_items.first
  end

  def update
    @order.update(order_params)
  end

  def set_express
    express = Express.find_or_create_by(name: express_params)
    if @order.update(order_params.merge(express_id: express.id)) && @order.ship!
      flash[:success] = '发货成功'
    else
      flash[:error] = '发货失败'
    end
    redirect_to admin_orders_path
  end

  private

  def validate_batch_shipment_params(param)
    param[:express_name].present? && param[:ship_number].present?
  end

  def validate_express_params
    errors = []
    errors << '快递公司名称不能为空' if express_params.blank?
    errors << '运单号不能为空' if order_params['ship_number'].blank?
    if errors.present?
      flash[:error] = errors.join('; ')
      redirect_to admin_orders_path and return
    end
  end

  def order_params
    params.require(:order).permit(:mobile, :address, :ship_number)
  end

  def express_params
    params[:express_name]
  end

  def record_operation
  end
end
