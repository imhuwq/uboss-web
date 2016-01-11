FactoryGirl.define do
  factory :supplier_product_inventory do
    cost_price "9.99"
suggest_price_lower "9.99"
suggest_price_upper "9.99"
quantity 1
for_sale false
product_inventory_id 1
  end

end
