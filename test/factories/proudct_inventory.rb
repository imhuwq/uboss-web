FactoryGirl.define do
  factory :product_inventory do
    product { create(:ordinary_product) }
    count 100
    price 99.0
    saling true
    sku_attributes do
        {'size' => 'x', 'color' => 'red'}
    end
  end
end
