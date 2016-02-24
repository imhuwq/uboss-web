require 'test_helper'

class Ubonus::InviteTest < ActiveSupport::TestCase

  test 'should inc inviter bonus & create reward bonus' do
    bonus_record = create(:bonus_invite, amount: 40)
    assert bonus_record.actived.blank?
    assert_equal 40, bonus_record.user.reload.bonus_benefit
    assert_equal 0, bonus_record.inviter.reload.bonus_benefit

    bonus_record.active!

    assert Ubonus::InviteReward.count > 0
    assert_equal 40, bonus_record.inviter.reload.bonus_benefit
    assert bonus_record.actived.present?
  end

end
