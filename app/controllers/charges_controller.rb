class ChargesController < ApplicationController

  include SharingResource

  before_action :authenticate_user!, only: [:payments, :pay_complete]
  before_action :authenticate_weixin_user_token!, only: [:pay_bill, :bill_complete]

  def pay_bill
    @service_store = ServiceStore.find(params.fetch(:ssid))
    @pay_amount = params[:pay_amount].present? ? params[:pay_amount].to_f : nil
  end

  def bill_complete
    @order_charge = if current_user.present?
                      current_user.order_charges.find(params[:id])
                    else
                      OrderCharge.joins(:bill_orders).
                        where(bill_orders: { weixin_openid: get_weixin_openid_form_session }).
                        find(params[:id])
                    end
    @order_charge.check_paid?
    @seller = @order_charge.bill_orders.first.seller
    @promotion_activity = PromotionActivity.find_by(user: @seller, status: 1)
    @service_store_valid = @seller.service_products.published.exists?
    set_sharing_link_node
  end

  def payments
    order_ids = params[:order_ids].split(',')
    orders = current_user.orders.where(id: order_ids).all
    return redirect_to root_path if orders.blank?

    unless ChargeService.available_pay?(orders)
      flash[:error] = orders.map { |order|
        "#{order.seller.store_identify}的订单，#{model_errors(order).join('、')}" if !order.errors.empty?
      }.compact.join('<br/>')
      return redirect_to account_path
    end

    trade_type = browser.wechat? ? ChargeService::WX_JS_TRADETYPE : ChargeService::WX_NATIVE_TRADETYPE
    @order_charge = ChargeService.find_or_create_charge(
      orders,
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
    render layout: 'mobile'
  end

  def pay_complete
    @order_charge = current_user.order_charges.find(params[:id])
    @order_charge.check_paid?
    @product = @order_charge.order_items.first.item_product
    @privilege_cards = @order_charge.orders.inject([]) { |cards, order| cards << PrivilegeCard.find_by(user: current_user, seller: order.seller) }
    render layout: 'mobile'
  end

end
