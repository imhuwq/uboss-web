FactoryGirl.define do
  factory :cart do
    user { create(:user) }
  end
end
