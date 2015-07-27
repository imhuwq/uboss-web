class Admin::OrdersController < AdminController
  load_and_authorize_resource

  # TODO record use operations
  after_action :record_operation, only: [:update, :ship]

  def index
    @orders = @orders.recent.page(param_page)
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

  def ship
    if @order.ship!
      flash.now[:notice] = '发货成功'
      redirect_to :back
    else
      flash.now[:notice] = '发货失败'
      redirect_to :back
    end
  end

  private
  def order_params
    params.require(:order).permit(:mobile, :address)
  end

  def record_operation
  end
end
