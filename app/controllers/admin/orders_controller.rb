class Admin::OrdersController < AdminController

  before_action :find_order, only: [:show, :update, :ship]
  after_action :record_operation, only: [:update, :ship]

  def index
    @orders = Order.page(param_page)
    @unship_amount = @orders.payed.total_count
    @today_selled_amount = @orders.today.selled.total_count
    @shiped_amount = @orders.shiped.total_count
  end

  def show
  end

  def update
    @order.update(order_params)
  end

  def ship
    if @order.ship!
      flash[:notice] = '发货成功'
      redirect_to :back
    else
      flash[:notice] = '发货失败'
      redirect_to :back
    end
  end

  private
  def order_params
    params.require(:order).permit(:mobile, :address)
  end

  def find_order
    @order ||= Order.find(params[:id])
  end

  def record_operation
  end
end
