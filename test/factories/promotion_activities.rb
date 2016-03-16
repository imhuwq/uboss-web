FactoryGirl.define do

  factory :promotion_activity do
    user
    factory :active_promotion_activity do
      status 1
    end
  end

end
