require 'test_helper'

class WagesControllerTest < ActionController::TestCase
  setup do
    @wage = wages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wage" do
    assert_difference('Wage.count') do
      post :create, wage: { FY: @wage.FY, NI_employee: @wage.NI_employee, NI_employer: @wage.NI_employer, PAYE: @wage.PAYE, employee_id: @wage.employee_id, hours: @wage.hours, money: @wage.money, net: @wage.net, paid_date: @wage.paid_date, rate: @wage.rate, tips: @wage.tips, week_no: @wage.week_no }
    end

    assert_redirected_to wage_path(assigns(:wage))
  end

  test "should xshow wage" do
    get :xshow, id: @wage
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wage
    assert_response :success
  end

  test "should update wage" do
    patch :update, id: @wage, wage: { FY: @wage.FY, NI_employee: @wage.NI_employee, NI_employer: @wage.NI_employer, PAYE: @wage.PAYE, employee_id: @wage.employee_id, hours: @wage.hours, money: @wage.money, net: @wage.net, paid_date: @wage.paid_date, rate: @wage.rate, tips: @wage.tips, week_no: @wage.week_no }
    assert_redirected_to wage_path(assigns(:wage))
  end

  test "should destroy wage" do
    assert_difference('Wage.count', -1) do
      delete :destroy, id: @wage
    end

    assert_redirected_to wages_path
  end
end
