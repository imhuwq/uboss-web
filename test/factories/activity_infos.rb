FactoryGirl.define do

  factory :activity_info do
    promotion_activity
    sequence :name do |n|
      "activity_info #{n}"
    end
    price 100
    expiry_days 60
    description "test activity info"
    win_count 50
    win_rate 50
    draw_count 0
    factory :live_activity_info do
      activity_type 'live'
    end
    factory :share_activity_info do
      activity_type 'share'
    end
  end

end
