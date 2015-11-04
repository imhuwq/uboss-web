class RefundTimeoutJob < ActiveJob::Base
  queue_as :default

  def perform
    seller_timeout
    buyer_timeout
  end

  private
  def seller_timeout
    refund_timeout = Rails.application.secrets.refund_timeout
    #退款申请处理
    @refunds = OrderItemRefund.where(aasm_state: 'pending', refund_type: 'refund').where("updated_at >= :date", date: Time.now - refund_timeout.days)
    @refunds.each do |refund|
      refund.may_approve? && refund.approve!
    end

    #退货申请处理
    @sales = OrderItemRefund.where(aasm_state: [:approved, :declined], refund_type: 'return_goods').where("updated_at >= :date", date: Time.now - refund_timeout.days)

    @sales.each do |sale|
      #TODO 退货地址信息
      sale.may_approve? && sale.approve!
    end
  end

  def buyer_timeout
    refund_timeout = Rails.application.secrets.refund_timeout
    @refunds = OrderItemRefund.where(aasm_state: [:approved, :declined, :decline_received]).where("updated_at >= :date", date: Time.now - refund_timeout.days)

    @refunds.each do |refund|
      refund.may_cancel && refund.cancel!
    end
  end
end
