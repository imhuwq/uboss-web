FactoryGirl.define do

  factory :supplier_product do
    type "SupplierProduct"
    sequence :name do |n|
      "Supplier Product #{n}"
    end
    user
    original_price 110
    present_price 100
    count 100
    status 1
    content "product desc"
    short_description "product short desc"
    transportation_way 1
    traffic_expense 10
    association :asset_img, strategy: :build
    association :supplier_product_info, strategy: :build, cost_price: 150, suggest_price_upper: 200, suggest_price_lower: 150.0
    supplier_product_inventories_attributes [
      {
        price: 100,
        suggest_price_lower: 150.0,
        suggest_price_upper: 200.0,
        count: 100,
        sku_attributes: { size: 'x', color: 'red' }
      }
    ]
  end
end
