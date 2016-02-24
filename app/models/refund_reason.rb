class RefundReason < ActiveRecord::Base
  has_many :order_item_refunds
  has_many :refund_messages

  extend Enumerize

  enumerize :reason_type, in: [:refund, :receipted_refund, :unreceipt_refund, :return_goods_and_refund, :after_sale_only_refund, :after_sale_return_goods_and_refund]


  scope :reason_type, ->(type) {
    case type
    when 'refund'
      where(reason_type: 'refund')
    when 'receipted_refund' || 'return_goods_and_refund'
      where(reason_type: 'receipted_refund')
    when 'unreceipt_refund'
      where(reason_type: 'unreceipt_refund')
    when 'after_sale_return_goods_and_refund' || 'after_sale_only_refund'
      where(reason_type: 'after_sale_return_goods_and_refund')
    else
      where(reason_type: 'refund')
    end
  }
end
