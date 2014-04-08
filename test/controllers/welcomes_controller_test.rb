require 'test_helper'

class WelcomesControllerTest < ActionController::TestCase
  setup do
    @welcome = welcomes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:welcome)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create welcome" do
    assert_difference('Welcome.count') do
      post :create, welcome: { index: @welcome.index }
    end

    assert_redirected_to welcome_path(assigns(:welcome))
  end

  test "should show welcome" do
    get :show, id: @welcome
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @welcome
    assert_response :success
  end

  test "should update welcome" do
    patch :update, id: @welcome, welcome: { index: @welcome.index }
    assert_redirected_to welcome_path(assigns(:welcome))
  end

  test "should destroy welcome" do
    assert_difference('Welcome.count', -1) do
      delete :destroy, id: @welcome
    end

    assert_redirected_to welcomes_path
  end
end
