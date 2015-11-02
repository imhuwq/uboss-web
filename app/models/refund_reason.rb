class RefundReason < ActiveRecord::Base
  has_many :order_item_refunds
end
