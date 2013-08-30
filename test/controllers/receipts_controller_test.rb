require 'test_helper'

class ReceiptsControllerTest < ActionController::TestCase
  setup do
    @receipt = receipts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:receipts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create receipt" do
    assert_difference('Receipt.count') do
      post :create, receipt: { amount: @receipt.amount, bank_id: @receipt.bank_id, exchange_rate: @receipt.exchange_rate, home_amount: @receipt.home_amount, receipt_date: @receipt.receipt_date, receivable_id: @receipt.receivable_id, receivable_type: @receipt.receivable_type, state: @receipt.state }
    end

    assert_redirected_to receipt_path(assigns(:receipt))
  end

  test "should show receipt" do
    get :show, id: @receipt
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @receipt
    assert_response :success
  end

  test "should update receipt" do
    patch :update, id: @receipt, receipt: { amount: @receipt.amount, bank_id: @receipt.bank_id, exchange_rate: @receipt.exchange_rate, home_amount: @receipt.home_amount, receipt_date: @receipt.receipt_date, receivable_id: @receipt.receivable_id, receivable_type: @receipt.receivable_type, state: @receipt.state }
    assert_redirected_to receipt_path(assigns(:receipt))
  end

  test "should destroy receipt" do
    assert_difference('Receipt.count', -1) do
      delete :destroy, id: @receipt
    end

    assert_redirected_to receipts_path
  end
end
