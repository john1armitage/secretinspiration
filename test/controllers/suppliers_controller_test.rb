require 'test_helper'

class SuppliersControllerTest < ActionController::TestCase
  setup do
    @supplier = suppliers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:suppliers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts supplier" do
    assert_difference('Supplier.count') do
      post :carts, supplier: { email: @supplier.email, name: @supplier.name, notes: @supplier.notes, opening_balance: @supplier.opening_balance, phone1: @supplier.phone1, phone2: @supplier.phone2 }
    end

    assert_redirected_to supplier_path(assigns(:supplier))
  end

  test "should xshow supplier" do
    get :xshow, id: @supplier
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @supplier
    assert_response :success
  end

  test "should update supplier" do
    patch :update, id: @supplier, supplier: { email: @supplier.email, name: @supplier.name, notes: @supplier.notes, opening_balance: @supplier.opening_balance, phone1: @supplier.phone1, phone2: @supplier.phone2 }
    assert_redirected_to supplier_path(assigns(:supplier))
  end

  test "should destroy supplier" do
    assert_difference('Supplier.count', -1) do
      delete :destroy, id: @supplier
    end

    assert_redirected_to suppliers_path
  end
end
