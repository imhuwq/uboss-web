require 'test_helper'

class Ubonus::GameTest < ActiveSupport::TestCase

  test "limit rate" do
    bonus_record = create(:bonus_game)
    user = bonus_record.user
    create(:bonus_game, user: user)
    record = build(:bonus_game, user: user)
    assert_equal true, record.save
    record = build(:bonus_game, user: user)
    assert_equal false, record.save

    travel_to Time.now + 1.day
    record = build(:bonus_game, user: user)
    assert_equal true, record.save
  end

end
