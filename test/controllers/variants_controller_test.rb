require 'test_helper'

class VariantsControllerTest < ActionController::TestCase
  setup do
    @variant = variants(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:variants)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts variant" do
    assert_difference('Variant.count') do
      post :carts, variant: { available_on: @variant.available_on, description: @variant.description, item_default: @variant.item_default, item_id: @variant.item_id, name: @variant.name, price: @variant.price, stock: @variant.stock }
    end

    assert_redirected_to variant_path(assigns(:variant))
  end

  test "should xshow variant" do
    get :xshow, id: @variant
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @variant
    assert_response :success
  end

  test "should update variant" do
    patch :update, id: @variant, variant: { available_on: @variant.available_on, description: @variant.description, item_default: @variant.item_default, item_id: @variant.item_id, name: @variant.name, price: @variant.price, stock: @variant.stock }
    assert_redirected_to variant_path(assigns(:variant))
  end

  test "should destroy variant" do
    assert_difference('Variant.count', -1) do
      delete :destroy, id: @variant
    end

    assert_redirected_to variants_path
  end
end
