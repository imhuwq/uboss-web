class RefundTimeoutJob < ActiveJob::Base
  queue_as :default

  def perform
    seller_timeout
    buyer_timeout
  end

  private
  def seller_timeout
    refund_timeout_2 = Rails.application.secrets.refund_timeout_2_days
    refund_timeout_5 = Rails.application.secrets.refund_timeout_5_days
    refund_timeout_10 = Rails.application.secrets.refund_timeout_10_days

    # 未发货 (退款)
    OrderItemRefund.where(aasm_state: 'pending', refund_type: 'refund')
      .where("updated_at >= :date", date: Time.now - refund_timeout_2.days)
      .each do |refund|
      refund.may_approve? && refund.approve! && refund.create_timeout_message(refund_timeout_2)
    end

    # 已收到货 (已收到货退款 / 未收到货退款 / 售后退款)
    OrderItemRefund.where(aasm_state: 'pending', refund_type: [:receipted_refund, :unreceipt_refund, :after_sale_only_refund])
      .where("updated_at >= :date", date: Time.now - refund_timeout_5.days)
      .each do |refund|
      refund.may_approve? && refund.approve! && refund.create_timeout_message(refund_timeout_5)
    end

    # 已收到货 (退款退货 / 售后退货)
    OrderItemRefund.where(aasm_state: 'pending', refund_type: [:return_goods_and_refund, :after_sale_return_goods_and_refund])
      .where("updated_at >= :date", date: Time.now - refund_timeout_5.days)
      .each do |refund|
      refund.may_approve? && refund.approve! && refund.create_timeout_message(refund_timeout_5)
      # TODO 发送退货地址信息 refund_message
    end

    # 卖家收货
    OrderItemRefund.where(aasm_state: 'completed_express_number')
      .where("updated_at >= :date", date: Time.now - refund_timeout_10.days)
      .each do |refund|
      refund.may_confirm_receive? && refund.confirm_receive! && refund.create_timeout_message(refund_timeout_10)
    end
  end

  def buyer_timeout
    refund_timeout_7 = Rails.application.secrets.refund_timeout_7_days

    # 等待买家回应：卖家拒绝退款申请/卖家拒绝退货申请/卖家拒绝确认收货
    # 等待买家退货
    OrderItemRefund.where(aasm_state: [:approved, :declined, :decline_received])
      .where("updated_at >= :date", date: Time.now - refund_timeout_7.days)
      .each do |refund|
      refund.may_cancel && refund.cancel!
    end
  end
end
