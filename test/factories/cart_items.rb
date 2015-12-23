FactoryGirl.define do
  factory :cart_item do
    cart
    count 1
    seller { create(:user) }
    product_inventory { create(:product_inventory, product: create(:ordinary_product, user: seller)) }
  end
end
