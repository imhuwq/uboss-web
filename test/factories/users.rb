FactoryGirl.define do

  factory :user do
    sequence(:login) { |n| "18912345#{rand(100)}#{n%10}" }
    password "superPassword"
  end

end
