require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts order" do
    assert_difference('Order.count') do
      post :carts, order: { adjustment_total: @order.adjustment_total, customer_id: @order.customer_id, decimal: @order.decimal, due_date: @order.due_date, effective_date: @order.effective_date, net_total: @order.net_total, notes: @order.notes, special_instructions: @order.special_instructions, state: @order.state, supplier_id: @order.supplier_id, tax_total: @order.tax_total, user_id: @order.user_id }
    end

    assert_redirected_to order_path(assigns(:order))
  end

  test "should xshow order" do
    get :xshow, id: @order
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @order
    assert_response :success
  end

  test "should update order" do
    patch :update, id: @order, order: { adjustment_total: @order.adjustment_total, customer_id: @order.customer_id, decimal: @order.decimal, due_date: @order.due_date, effective_date: @order.effective_date, net_total: @order.net_total, notes: @order.notes, special_instructions: @order.special_instructions, state: @order.state, supplier_id: @order.supplier_id, tax_total: @order.tax_total, user_id: @order.user_id }
    assert_redirected_to order_path(assigns(:order))
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete :destroy, id: @order
    end

    assert_redirected_to orders_path
  end
end
