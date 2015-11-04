class ChargesController < ApplicationController

  before_action :authenticate_user!
  before_action :find_order_charge, only: [:pay_complete]

  def payments
    order_ids = params[:order_ids].split(',')
    @orders = current_user.orders.where(id: order_ids).all
    return redirect_to root_path if @orders.blank?

    unless ChargeService.available_pay?(@orders)
      flash[:error] = @orders.map { |order|
        "#{order.seller.store_identify}的订单，#{model_errors(order).join('、')}" if !order.errors.empty?
      }.compact.join('<br/>')
      return redirect_to account_path
    end

    trade_type = browser.wechat? ? 'JSAPI' : 'NATIVE'
    @order_charge = ChargeService.find_or_create_charge(
      @orders,
      remote_ip: request.ip,
      trade_type: trade_type
    )
    @pay_p = {
      appId: WxPay.appid,
      timeStamp: Time.now.to_i.to_s,
      nonceStr: SecureRandom.hex,
      package: "prepay_id=#{@order_charge.prepay_id}",
      signType: "MD5"
    }
    p @pay_p
    @pay_sign = WxPay::Sign.generate(@pay_p)
    render layout: 'mobile'
  end

  def pay_complete
    @order_charge.orders_check_paid
    @orders = @order_charge.orders
    @product = @order_charge.order_items.first.item_product
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
