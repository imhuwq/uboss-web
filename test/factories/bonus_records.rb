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

  factory :bonus_invite, class: Ubonus::Invite do
    user
    amount "20"
    inviter { create(:user) }
  end

  factory :bonus_invite_reward, class: Ubonus::InviteReward do
    user
    bonus_resource { create(:bonus_invite) }
    amount "1.99"
  end

end
