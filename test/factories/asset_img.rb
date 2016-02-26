FactoryGirl.define do
  factory :asset_img do
    after(:build) { |img| img.write_uploader :avatar, "uboss.logo" }
  end
end
