FactoryGirl.define do

  factory :product do
    type ['OrdinaryProduct', 'ServiceProduct'].sample
    sequence :name do |n|
      "Product #{n}"
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
    product_inventories_attributes [{ price: 100, count: 100, sku_attributes: { size: 'x', color: 'red' } }]
    avatar 'fake.jpg'
  end

end
