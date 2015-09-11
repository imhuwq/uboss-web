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

    trait :sharing_thr do
      calculate_way 0
      share_amount_total 20
      has_share_lv 3
    end

    trait :sharing_one do
      calculate_way 0
      share_amount_total 20
      has_share_lv 1
    end

    factory :product_with_3sharing, traits: [:sharing_thr]
    factory :product_with_1sharing, traits: [:sharing_one]
  end

end
