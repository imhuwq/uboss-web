require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  before do
    @user = create(:user)
    current_user
    sign_in @user
  end

  test "should get followers" do
    get(:followers, {login: @user.login})
    assert_response :success
  end

  test "should get following" do
    get(:following, {login: @user.login})
    assert_response :success
  end

  test "current user follow some one" do
    user2 = create(:user)
    get(:follow, {login: @user.login, user_id: user2.id})
    assert_response :success
  end

  test "current user unfollow some one" do
    user2 = create(:user)
    get(:follow, {login: @user.login, user_id: user2.id})
    get(:unfollow, {login: @user.login, user_id: user2.id})
    assert_response :success
  end
end
