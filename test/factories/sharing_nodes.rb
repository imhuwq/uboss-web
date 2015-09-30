FactoryGirl.define do

  factory :sharing_node do
    user

    factory :sharing_node_with_seller do
      seller { create(:user) }
    end

    factory :sharing_node_with_product do
      product
    end

  end

end
