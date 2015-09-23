require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  setup do
    @item = items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts item" do
    assert_difference('Item.count') do
      post :carts, item: { name: @item.name }
    end

    assert_redirected_to item_path(assigns(:item))
  end

  test "should xshow item" do
    get :xshow, id: @item
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @item
    assert_response :success
  end

  test "should update item" do
    patch :update, id: @item, item: { name: @item.name }
    assert_redirected_to item_path(assigns(:item))
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete :destroy, id: @item
    end

    assert_redirected_to items_path
  end
end
