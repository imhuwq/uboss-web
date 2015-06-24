FactoryGirl.define do

  factory :user do
    sequence(:login) { |n| "18912345#{rand(100)}#{n%10}" }
    password "superPassword"

    factory :user_with_address do
      after(:create) do |user|
        create(:user_address, user: user, default: true)
      end
    end

    factory :user_with_onek_income do
      after(:create) do |user|
        create(:user_info, user: user, income: 1000)
      end
    end
  end

end
