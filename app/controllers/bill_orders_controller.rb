class BillOrdersController < ApplicationController

  before_action :authenticate_user!, only: [:index, :show]
  before_action :authenticate_weixin_user_token!, only: [:create]

  def index
    @bill_orders = append_default_filter current_user.bill_orders.payed
  end

  def show
    @bill_order = current_user.bill_orders.find(params[:id])
  end

  def create
    @service_store = ServiceStore.find(params[:ssid])
    trade_type = browser.wechat? ? ChargeService::WX_JS_TRADETYPE : ChargeService::WX_NATIVE_TRADETYPE
    @order_charge = ChargeService.create_bill_charge(
      service_store: @service_store,
      pay_amount: params[:pay_amount],
      user: current_user,
      weixin_openid: get_weixin_openid_form_session,
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
    @pay_sign = WxPay::Sign.generate(@pay_p)

    render json: @pay_p.merge(sign: @pay_sign, order_charge_id: @order_charge.id, pay_amount: params[:pay_amount])
  end

end
