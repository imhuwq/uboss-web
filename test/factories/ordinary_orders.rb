FactoryGirl.define do
  factory :ordinary_order do
    user
    seller { create(:user) }
    user_address { create(:user_address, user: user) }

    factory :order_with_item do

      after :create do |order|
        create(:order_item, order: order)
        order.reload.send(:invoke_privielge_calculator)
      end

    end
  end

end
