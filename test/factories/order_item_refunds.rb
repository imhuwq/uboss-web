FactoryGirl.define do
  factory :order_item_refund do
    money "9.99"
reason_id 1
description "MyString"
order_item_id 1
  end

end
