require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  setup do
    @category = categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts category" do
    assert_difference('Category.count') do
      post :carts, category: { ancestry: @category.ancestry, name: @category.name }
    end

    assert_redirected_to category_path(assigns(:category))
  end

  test "should xshow category" do
    get :xshow, id: @category
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @category
    assert_response :success
  end

  test "should update category" do
    patch :update, id: @category, category: { ancestry: @category.ancestry, name: @category.name }
    assert_redirected_to category_path(assigns(:category))
  end

  test "should destroy category" do
    assert_difference('Category.count', -1) do
      delete :destroy, id: @category
    end

    assert_redirected_to categories_path
  end
end
