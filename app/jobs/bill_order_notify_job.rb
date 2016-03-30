class BillOrderNotifyJob < ActiveJob::Base

  queue_as :default

  attr_reader :bill_order, :seller, :user, :user_name

  def perform(bill_order)
    @bill_order = bill_order.reload
    @seller = bill_order.seller
    @user = bill_order.user
    @payer_weixin_openid = @user.weixin_openid || bill_order.weixin_openid

    @user_name = "微信用户"
    if user.blank? && payer_weixin_openid.present?
      user_response = weixin_client.user(scan_weixin_openid)
      @user_name = user_response.result['nickname'] if user_response.is_ok?
    else
      @user_name = user.identify
    end

    notify_seller
    notify_user
  end

  private

  def notify_seller
    return false if seller.weixin_openid.blank?

    message = <<-MSG
#{user_name} 成功支付 #{bill_order.paid_amount} 到您的店铺
#{pay_info}
    MSG
    $weixin_client.send_text_custom(
      seller.weixin_openid,
      message
    )
  end

  def notify_user
    return false if @payer_weixin_openid.blank?

    $weixin_client.send_text_custom(
      @payer_weixin_openid,
      <<-MSG
您已成功支付 #{bill_order.paid_amount} 到UBOSS 实体店铺: [#{seller.service_store.store_name}]"
#{pay_info}
      MSG
    )
  end

  def pay_info
    @pay_info ||= <<-MSG
付款单号：#{bill_order.order_charge.pay_serial_number}
订单号：#{bill_order.number}
    MSG
  end
end
