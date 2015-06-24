FactoryGirl.define do
  factory :withdraw_record do
    user
    bank_card { create(:bank_card, user: user) }

    amount 100
  end

end
