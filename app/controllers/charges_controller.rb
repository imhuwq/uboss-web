class ChargesController < ApplicationController
  before_action :find_order_charge, only: [:payments, :pay_complete]

  def create
    @order = Order.find(params[:order_id])
    @order_charge = ChargeService.find_or_create_charge(@order, remote_ip: request.ip)
    @pay_p = {
      appId: WxPay.appid,
      timeStamp: Time.now.to_i.to_s,
      nonceStr: SecureRandom.hex,
      package: "prepay_id=#{@order_charge.prepay_id}",
      signType: "MD5"
    }
    p @pay_p
    @pay_sign = WxPay::Sign.generate(@pay_p)

    render json: {
      timestamp: @pay_p[:timeStamp],
      nonceStr: @pay_p[:nonceStr],
      package: @pay_p[:package],
      signType: @pay_p[:signType],
      paySign: @pay_sign,
      order_id: @order.id
    }
  end

  def payments
    render layout: 'mobile'
  end

  def pay_complete
    #@order.check_paid
    @orders = @order_charge.orders
    @product = @order_charge.order_items.first.product
    @privilege_cards = @orders.inject([]) { |cards, order| cards << PrivilegeCard.find_by(user: current_user, seller: order.seller) }
    render layout: 'mobile'
  end

  private

  def find_order_charge
    @order_charge = OrderCharge.find(params[:id])

    if @order_charge.orders.first.user_id != current_user.id
      redirect_to root_path
    end
  end
end
