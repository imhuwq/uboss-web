FactoryGirl.define do
  factory :order_item do
    order { create(:ordinary_order) }
    product { create(:ordinary_product, user: order.seller) }
    product_inventory { create(:product_inventory, product: product) }
    user { order.user }
    amount 1
  end

end
