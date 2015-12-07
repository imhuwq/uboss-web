FactoryGirl.define do
  factory :order_item_refund do
    money "9.99"
    refund_reason { create(:refund_reason) }
    description "MyString"
    order_item { create(:order_item) }
    order_state { order_item.order.state }
    refund_type 'refund'
    user { order_item.user }
  end

end
