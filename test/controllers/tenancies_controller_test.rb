require 'test_helper'

class TenanciesControllerTest < ActionController::TestCase
  setup do
    @tenancies_controller = tenancies_controllers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tenancies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts tenancies_controller" do
    assert_difference('TenanciesController.count') do
      post :carts, tenancies_controller: {  }
    end

    assert_redirected_to tenancies_controller_path(assigns(:tenancies_controller))
  end

  test "should xshow tenancies_controller" do
    get :xshow, id: @tenancies_controller
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @tenancies_controller
    assert_response :success
  end

  test "should update tenancies_controller" do
    patch :update, id: @tenancies_controller, tenancies_controller: {  }
    assert_redirected_to tenancies_controller_path(assigns(:tenancies_controller))
  end

  test "should destroy tenancies_controller" do
    assert_difference('TenanciesController.count', -1) do
      delete :destroy, id: @tenancies_controller
    end

    assert_redirected_to tenancies_controllers_path
  end
end
