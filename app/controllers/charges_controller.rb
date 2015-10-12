class ChargesController < ApplicationController

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

  def payment
  end

end
