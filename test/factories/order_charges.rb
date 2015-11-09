FactoryGirl.define do
  factory :order_charge do
    user
    prepay_id "prepay_id-in-factory-girl"
    wx_code_url 'fake-prepay-url'
    wx_trade_type 'JSAPI'
    prepay_id_expired_at Time.current + 2.hours

    trait :paid_order_charge do
      paid_at { Time.current }
    end

    trait :with_orders do
      transient do
        orders_count 3
      end

      after(:create) do |order_charge, evaluator|
        create_list(:order, evaluator.orders_count, order_charge: order_charge, user: order_charge.user)
      end
    end

    factory :charge_with_orders, traits: [:with_orders]

    factory :paid_order_charge_with_orders, traits: [:paid_order_charge, :with_orders] do
      paid_amount { orders.sum(:pay_amount) }
    end

  end

end
