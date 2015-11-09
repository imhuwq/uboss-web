FactoryGirl.define do
  factory :order_item do
    order
    product { create(:product, user: order.seller) }
    product_inventory { create(:product_inventory, product: product) }
    user { order.user }
    amount 1
  end

end
