FactoryGirl.define do
  factory :product_inventory do
    product
    count 100
    price 99.0
    sku_attributes do
        {'size' => 'x', 'color' => 'red'}
    end
  end
end
