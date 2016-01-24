FactoryGirl.define do
  factory :supplier_product do
    sequence :name do |n|
      "Product #{n}"
    end
    user
  end

end
