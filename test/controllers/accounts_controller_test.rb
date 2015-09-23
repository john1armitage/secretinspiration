require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  setup do
    @account = accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts account" do
    assert_difference('Account.count') do
      post :carts, account: { ancestry: @account.ancestry, code: @account.code, name: @account.name, opening_balance: @account.opening_balance }
    end

    assert_redirected_to account_path(assigns(:account))
  end

  test "should xshow account" do
    get :xshow, id: @account
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @account
    assert_response :success
  end

  test "should update account" do
    patch :update, id: @account, account: { ancestry: @account.ancestry, code: @account.code, name: @account.name, opening_balance: @account.opening_balance }
    assert_redirected_to account_path(assigns(:account))
  end

  test "should destroy account" do
    assert_difference('Account.count', -1) do
      delete :destroy, id: @account
    end

    assert_redirected_to accounts_path
  end
end
