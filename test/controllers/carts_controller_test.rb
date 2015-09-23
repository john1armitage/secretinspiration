require 'test_helper'

class CartsControllerTest < ActionController::TestCase
  setup do
    @cart = carts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:carts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts carts" do
    assert_difference('Cart.count') do
      post :carts, carts: {  }
    end

    assert_redirected_to cart_path(assigns(:carts))
  end

  test "should xshow carts" do
    get :xshow, id: @cart
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @cart
    assert_response :success
  end

  test "should update carts" do
    patch :update, id: @cart, carts: {  }
    assert_redirected_to cart_path(assigns(:carts))
  end

  test "should destroy carts" do
    assert_difference('Cart.count', -1) do
      delete :destroy, id: @cart
    end

    assert_redirected_to carts_path
  end
end
