FactoryGirl.define do
  factory :order_item do
    order
    product { create(:product, user: order.seller) }
    user { order.user }
    amount 1
  end

end
