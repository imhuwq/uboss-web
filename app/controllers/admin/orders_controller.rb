class Admin::OrdersController < AdminController
  def index
    @orders = Order.page(param_page)
    @unship_amount = @orders.payed.total_count
    @today_selled_amount = @orders.today.selled.total_count
    @shiped_amount = @orders.shiped.total_count
  end

  def show

  end

  def update

  end
end
