require 'test_helper'

class UserTest < ActiveSupport::TestCase
  it 'should auto create user_info after created' do
    assert UserInfo.count == 0
    user = create(:user)
    assert_equal 1, User.count
    assert_equal 1, UserInfo.count
    assert user.reload.user_info.persisted?
  end
end
