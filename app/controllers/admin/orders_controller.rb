class Admin::OrdersController < AdminController
  load_and_authorize_resource

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
  def order_params
    params.require(:order).permit(:mobile, :address, :ship_number)
  end

  def express_params
    params[:express_name]
  end

  def record_operation
  end
end
