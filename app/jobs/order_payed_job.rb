class OrderPayedJob < ActiveJob::Base

  class OrderNotPayed < StandardError; ;end

  queue_as :default

  attr_reader :order, :seller, :buyer, :agent

  def perform(order)
    @order = order.reload
    @seller = order.seller
    @buyer = order.user
    @agent = @seller && @seller.agent
    raise OrderNotPayed, order.attributes if !order.payed?

    create_privilege_card_if_none
    send_payed_sms_to_seller
    send_payed_wx_template_msg
  end

  private

  def create_privilege_card_if_none
    PrivilegeCard.find_or_active_card(buyer.id, seller.id)
  end

  def send_payed_sms_to_seller
    if seller
      PostMan.send_sms(seller.login, {name: seller.identify}, 968369)
    end
  end

  def send_payed_wx_template_msg
    WxTemplateMsg.order_payed_msg_to_seller(seller.weixin_openid, order) if seller && seller.weixin_openid.present?
    WxTemplateMsg.order_payed_msg_to_buyer(buyer.weixin_openid,   order) if buyer  && buyer.weixin_openid.present?
    WxTemplateMsg.order_payed_msg_to_agent(agent.weixin_openid,   order) if agent  && agent.weixin_openid.present?
  end

end
