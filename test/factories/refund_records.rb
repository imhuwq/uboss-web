FactoryGirl.define do
  factory :refund_record do
    order_item_refund nil
    refund_fee "9.99"
    applied_at "2015-11-13 09:55:06"
    transaction_id "MyString"
    refund_channel "MyString"
  end

end
