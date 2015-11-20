class RefundTimeoutJob < ActiveJob::Base
  queue_as :default

  def perform
    seller_timeout
    buyer_timeout
  end

  private

  def seller_timeout
    refund_timeout_2_days = Rails.application.secrets.refund_timeout['days_2']
    refund_timeout_5_days = Rails.application.secrets.refund_timeout['days_5']
    refund_timeout_10_days = Rails.application.secrets.refund_timeout['days_10']

    # 未发货 (退款)
    @refunds = OrderItemRefund.where(aasm_state: :pending, refund_type: :refund)
      .where("deal_at >= :date", date: Time.now - refund_timeout_2_days.days)

    # 已收到货 (已收到货退款 / 未收到货退款 / 售后退款 / 退款退货 / 售后退货)
    @refunds += OrderItemRefund.where(aasm_state: :pending)
      .where.not(refund_type: :refund)
      .where("deal_at >= :date", date: Time.now - refund_timeout_5_days.days)

    @refunds.each { |refund| refund.timeout_approve }

    # 买家填写完快递信息
    OrderItemRefund.where(aasm_state: :completed_express_number)
      .where("deal_at >= :date", date: Time.now - refund_timeout_10_days.days)
      .each { |refund| refund.timeout_confirm_receive }

  end

  def buyer_timeout
    # 等待买家回应：卖家拒绝退款申请/卖家拒绝退货申请/卖家拒绝确认收货
    # 等待买家退货
    OrderItemRefund.where(aasm_state: [:approved, :declined, :decline_received])
      .where("deal_at >= :date", date: Time.now - Rails.application.secrets.refund_timeout['days_7'].days)
      .each { |refund| refund.timeout_cancel }

  end
end
