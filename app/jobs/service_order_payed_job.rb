class ServiceOrderPayedJob < ActiveJob::Base

  class ServiceOrderNotPayed < StandardError; ;end

  queue_as :default

  attr_reader :order, :seller, :buyer

  def perform(order)
    @order = order
    @seller = order.seller
    @buyer = order.user
    raise ServiceOrderNotPayed, order if !order.payed?

    create_privilege_card_if_none
    send_payed_sms_to_buyer
    send_payed_wx_template_msg
  end

  private

  def create_privilege_card_if_none
    PrivilegeCard.find_or_active_card(buyer.id, seller.id)
  end

  def send_payed_sms_to_buyer
    name = order.order_item.product_name
    codes = order.verify_codes.map(&:code).join(', ')
    time = order.order_item.product.deadline.strftime('%Y-%m-%d')
    if buyer
      PostMan.send_sms(buyer.login, {name: name, codes: codes, time: time}, 1188511)
    end
  end

  def send_payed_wx_template_msg
    WxTemplateMsg.service_order_payed_msg_to_buyer(buyer.weixin_openid, order) if buyer && buyer.weixin_openid.present?
  end

end
