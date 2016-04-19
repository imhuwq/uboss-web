require 'test_helper'

class MenusControllerTest < ActionController::TestCase
  setup do
    @menu = menus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:menus)
  end

  test "should create menu" do
    assert_difference('Menu.count') do
      post :create, menu: {  }
    end

    assert_response 201
  end

  test "should show menu" do
    get :show, id: @menu
    assert_response :success
  end

  test "should update menu" do
    put :update, id: @menu, menu: {  }
    assert_response 204
  end

  test "should destroy menu" do
    assert_difference('Menu.count', -1) do
      delete :destroy, id: @menu
    end

    assert_response 204
  end
end
