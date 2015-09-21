class Admin::OrdersController < AdminController
  load_and_authorize_resource

  before_filter :validate_express_params, only: :set_express
  # TODO record use operations
  after_action :record_operation, only: [:update]

  def index
    @orders = append_default_filter @orders.recent
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
