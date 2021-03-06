require 'test_helper'

class LineItemsControllerTest < ActionController::TestCase
  setup do
    @line_item = line_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:line_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts line_item" do
    assert_difference('LineItem.count') do
      post :carts, line_item: { carts: @line_item.cart, destroy: @line_item.destroy, update: @line_item.update }
    end

    assert_redirected_to line_item_path(assigns(:line_item))
  end

  test "should xshow line_item" do
    get :xshow, id: @line_item
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @line_item
    assert_response :success
  end

  test "should update line_item" do
    patch :update, id: @line_item, line_item: { carts: @line_item.cart, destroy: @line_item.destroy, update: @line_item.update }
    assert_redirected_to line_item_path(assigns(:line_item))
  end

  test "should destroy line_item" do
    assert_difference('LineItem.count', -1) do
      delete :destroy, id: @line_item
    end

    assert_redirected_to line_items_path
  end
end
