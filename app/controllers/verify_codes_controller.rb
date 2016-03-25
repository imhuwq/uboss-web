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
  end

  def lottery_detail
    @activity_prize = ActivityPrize.find(params[:id])
    @verify_code = VerifyCode.find_by(activity_prize_id: @activity_prize.id)
    @activity_info = @activity_prize.activity_info
  end

end
