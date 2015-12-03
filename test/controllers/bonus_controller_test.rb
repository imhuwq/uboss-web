require 'test_helper'

class BonusControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

end
