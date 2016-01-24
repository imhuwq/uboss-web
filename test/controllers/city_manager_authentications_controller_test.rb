require 'test_helper'

class Admin::CityManagerAuthenticationsControllerTest < ActionController::TestCase
  setup do
    @city_manager_authentication = city_manager_authentications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:city_manager_authentications)
  end

  test "should create city_manager_authentication" do
    assert_difference('CityManagerAuthentication.count') do
      post :create, city_manager_authentication: {  }
    end

    assert_response 201
  end

  test "should show city_manager_authentication" do
    get :show, id: @city_manager_authentication
    assert_response :success
  end

  test "should update city_manager_authentication" do
    put :update, id: @city_manager_authentication, city_manager_authentication: {  }
    assert_response 204
  end

  test "should destroy city_manager_authentication" do
    assert_difference('CityManagerAuthentication.count', -1) do
      delete :destroy, id: @city_manager_authentication
    end

    assert_response 204
  end
end
