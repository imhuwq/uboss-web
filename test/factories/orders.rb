FactoryGirl.define do
  factory :order do
    user
    seller { create(:user) }
    user_address { create(:user_address, user: user) }

    factory :order_with_item do

      after :create do |order|
        create(:order_item, order: order)
      end

    end
  end

end
