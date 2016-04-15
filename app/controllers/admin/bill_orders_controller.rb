class Admin::BillOrdersController < AdminController

  load_and_authorize_resource

  def index
    @bill_orders = append_default_filter @bill_orders.payed
  end

end
