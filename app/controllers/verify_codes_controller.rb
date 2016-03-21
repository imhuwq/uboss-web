class VerifyCodesController < ApplicationController

  layout 'mobile'

  before_action :authenticate_user!

  def index
    @service_orders = ServiceOrder.where(user_id: current_user.id).payed.includes(order_items: { product_inventory: { product: :asset_img } })
  end

  def show
    order_item = OrderItem.find(params[:id])
    @verify_codes = order_item.verify_codes
  end

  def lotteries
    @activity_prizes = ActivityPrize.where(prize_winner_id: current_user.id)
    @verify_codes = VerifyCode.where(id: @activity_prizes.collect(&:verify_code_id) )
  end

end
