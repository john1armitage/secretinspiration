require 'test_helper'

class CreateOptionsControllerTest < ActionController::TestCase
  setup do
    @create_option = create_options(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:options)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create create_option" do
    assert_difference('Option.count') do
      post :create, create_option: { name: @create_option.name }
    end

    assert_redirected_to create_option_path(assigns(:create_option))
  end

  test "should xshow create_option" do
    get :xshow, id: @create_option
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @create_option
    assert_response :success
  end

  test "should update create_option" do
    patch :update, id: @create_option, create_option: { name: @create_option.name }
    assert_redirected_to create_option_path(assigns(:create_option))
  end

  test "should destroy create_option" do
    assert_difference('Option.count', -1) do
      delete :destroy, id: @create_option
    end

    assert_redirected_to create_options_path
  end
end
