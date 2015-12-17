class VerifyCodesController < ApplicationController

  layout 'mobile'

  before_action :authenticate_user!

  def index
    @service_orders = current_user.service_orders.payed.includes(order_items: { product_inventory: { product: :asset_img } })
  end

  def show
    order_item = OrderItem.find(params[:id])
    @verify_codes = order_item.verify_codes
  end

end
