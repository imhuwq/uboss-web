require 'test_helper'

class Admin::OperatorsControllerTest < ActionController::TestCase
  setup do
    @admin_operator = admin_operators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_operators)
  end

  test "should create admin_operator" do
    assert_difference('Admin::Operator.count') do
      post :create, admin_operator: {  }
    end

    assert_response 201
  end

  test "should show admin_operator" do
    get :show, id: @admin_operator
    assert_response :success
  end

  test "should update admin_operator" do
    put :update, id: @admin_operator, admin_operator: {  }
    assert_response 204
  end

  test "should destroy admin_operator" do
    assert_difference('Admin::Operator.count', -1) do
      delete :destroy, id: @admin_operator
    end

    assert_response 204
  end
end
