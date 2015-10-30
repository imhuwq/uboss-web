FactoryGirl.define do

  factory :product do
    sequence :name do |n|
      "Product #{n}"
    end
    user
    original_price 110
    present_price 100
    count 100
    content "product desc"
    short_description "product short desc"
    product_inventories_attributes [{ price: 100, count: 100, sku_attributes: { size: 'x', color: 'red' } }]

    trait :sharing_thr do
      product_inventories_attributes [
        {
          price: 100,
          count: 100,
          share_amount_lv_1: 10,
          share_amount_lv_2: 5,
          share_amount_lv_3: 2,
          privilege_amount: 5,
          sku_attributes: { size: 'x', color: 'red' }
        }
      ]
    end

    trait :sharing_one do
      product_inventories_attributes [
        {
          price: 100,
          count: 100,
          share_amount_lv_1: 10,
          privilege_amount: 5,
          sku_attributes: { size: 'x', color: 'red' }
        }
      ]
    end

    factory :product_with_3sharing, traits: [:sharing_thr]
    factory :product_with_1sharing, traits: [:sharing_one]
  end

end
