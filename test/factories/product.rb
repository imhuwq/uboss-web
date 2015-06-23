FactoryGirl.define do

  factory :product do
    sequence :name do |n|
      "Product #{n}"
    end
    user
    original_price 10
    present_price 8
    count 100
    content "product desc"
  end

end
