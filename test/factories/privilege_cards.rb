FactoryGirl.define do
  factory :privilege_card do
    user
    seller { create(:user) }
  end
end
