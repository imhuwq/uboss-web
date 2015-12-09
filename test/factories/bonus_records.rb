FactoryGirl.define do

  factory :bonus_record do
    user
    amount "9.99"
    type 'fake'
  end

  factory :bonus_game, class: Ubonus::Game do
    user
    amount "1.99"
  end

end
