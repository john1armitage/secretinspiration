require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  setup do
    financial = transactions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:financials)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transaction" do
    assert_difference('Transaction.count') do
      post :create, financial: { credit_amount: financial.credit_amount, debit_amount: financial.debit_amount, event_date: financial.event_date, reference: financial.reference }
    end

    assert_redirected_to transaction_path(assigns(:financial))
  end

  test "should show transaction" do
    get :show, id: financial
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: financial
    assert_response :success
  end

  test "should update transaction" do
    patch :update, id: financial, financial: { credit_amount: financial.credit_amount, debit_amount: financial.debit_amount, event_date: financial.event_date, reference: financial.reference }
    assert_redirected_to transaction_path(assigns(:financial))
  end

  test "should destroy transaction" do
    assert_difference('Transaction.count', -1) do
      delete :destroy, id: financial
    end

    assert_redirected_to transactions_path
  end
end
