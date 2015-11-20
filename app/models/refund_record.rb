class RefundRecord < ActiveRecord::Base
  belongs_to :order_item_refund

  #validates_presence_of   :out_trade_no, :out_refund_no, :total_fee, :refund_fee, :applied_at
  validates_uniqueness_of :out_refund_no

  before_create :set_out_refund_no

  private

  def set_out_refund_no
    self.out_trade_no  = order_item_refund.order_charge_number
    self.out_refund_no = order_item_refund.refund_number
    self.total_fee     = order_item_refund.total_fee
    self.refund_fee    = order_item_refund.money * 100
    self.applied_at    = Time.current
  end
end
