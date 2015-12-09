require 'test_helper'

class BonusRecordTest < ActiveSupport::TestCase

  test 'should increase_user_bonus_benefit' do
    user = create(:user)
    assert_equal 0, user.bonus_benefit

    create(:bonus_record, user: user, amount: 100)
    assert_equal 100, user.reload.bonus_benefit
  end

end
