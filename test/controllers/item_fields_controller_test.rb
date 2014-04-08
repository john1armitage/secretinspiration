require 'test_helper'

class ItemFieldsControllerTest < ActionController::TestCase
  setup do
    @item_field = item_fields(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:item_fields)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts item_field" do
    assert_difference('ItemField.count') do
      post :carts, item_field: { field_type: @item_field.field_type, item_type: @item_field.item_type, name: @item_field.name, required: @item_field.required }
    end

    assert_redirected_to item_field_path(assigns(:item_field))
  end

  test "should show item_field" do
    get :show, id: @item_field
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @item_field
    assert_response :success
  end

  test "should update item_field" do
    patch :update, id: @item_field, item_field: { field_type: @item_field.field_type, item_type: @item_field.item_type, name: @item_field.name, required: @item_field.required }
    assert_redirected_to item_field_path(assigns(:item_field))
  end

  test "should destroy item_field" do
    assert_difference('ItemField.count', -1) do
      delete :destroy, id: @item_field
    end

    assert_redirected_to item_fields_path
  end
end
