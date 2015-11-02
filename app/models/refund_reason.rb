class RefundReason < ActiveRecord::Base
  has_many :order_item_refunds
  has_many :refund_messages
end
