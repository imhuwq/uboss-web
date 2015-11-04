class Admin::OrderItemRefundsController < AdminController
  load_and_authorize_resource

  def index
    @order_item = OrderItem.find(params[:order_item_id])
    @refund_message = RefundMessage.new
  end

end
