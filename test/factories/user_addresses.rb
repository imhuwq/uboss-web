FactoryGirl.define do

  factory :user_address do
    user
    username 'username'
    mobile '13800001111'
    province 'province'
    city 'city'
    area 'area'
    building 'building'
    country 'country'
    street 'street'
  end

end
