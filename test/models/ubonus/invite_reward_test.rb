require 'test_helper'

class Ubonus::InviteRewardTest < ActiveSupport::TestCase

  test 'should set bonus_resource' do
    record = build(:bonus_invite_reward, bonus_resource: nil)
    assert_equal false, record.save
    record.bonus_resource = create(:bonus_invite)
    assert_equal true, record.save
  end

end
