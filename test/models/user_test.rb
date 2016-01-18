require 'test_helper'

class UserTest < ActiveSupport::TestCase
  it 'should auto create user_info after created' do
    assert UserInfo.count == 0
    user = create(:user)
    assert_equal 1, User.count
    assert_equal 2, UserInfo.count
    assert user.reload.user_info.persisted?
  end

  describe "privilege_rate" do
    it 'should be integer & between 0 and 100' do
      user = build(:user)
      assert user.valid?
      assert_equal 50, user.privilege_rate
      assert_not user.update(privilege_rate: 1001)
      assert_not user.update(privilege_rate: -10)
      assert user.update(privilege_rate: 10.8)
      assert_equal 10, user.privilege_rate
      assert user.update(privilege_rate: 0)
      assert user.update(privilege_rate: 100)
    end
  end

  describe "Guest" do
    it 'should be new & valid' do
      user = User.new_guest('13808080909')
      assert user.valid?
    end

    it 'should create guest successfully' do
      assert_equal 0, User.count
      User.create_guest('13808080912')
      assert_equal 1, User.count
    end
  end
end
