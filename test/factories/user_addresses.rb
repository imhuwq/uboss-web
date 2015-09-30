FactoryGirl.define do

  factory :user_address do
    user
    username 'username'
    mobile '13800001111'
    province '440000'
    city '440300'
    area '440305'
    building 'building'
    country 'country'
    street 'street'
  end

end
