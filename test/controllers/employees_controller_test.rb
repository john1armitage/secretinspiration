require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase
  setup do
    @employee = employees(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employees)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create employee" do
    assert_difference('Employee.count') do
      post :create, employee: { address1: @employee.address1, address2: @employee.address2, date_of_birth: @employee.date_of_birth, end_date: @employee.end_date, first_name: @employee.first_name, home_phone: @employee.home_phone, last_name: @employee.last_name, mobile_phone: @employee.mobile_phone, ni_number: @employee.ni_number, postcode: @employee.postcode, start_date: @employee.start_date, title: @employee.title, town: @employee.town }
    end

    assert_redirected_to employee_path(assigns(:employee))
  end

  test "should xshow employee" do
    get :xshow, id: @employee
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @employee
    assert_response :success
  end

  test "should update employee" do
    patch :update, id: @employee, employee: { address1: @employee.address1, address2: @employee.address2, date_of_birth: @employee.date_of_birth, end_date: @employee.end_date, first_name: @employee.first_name, home_phone: @employee.home_phone, last_name: @employee.last_name, mobile_phone: @employee.mobile_phone, ni_number: @employee.ni_number, postcode: @employee.postcode, start_date: @employee.start_date, title: @employee.title, town: @employee.town }
    assert_redirected_to employee_path(assigns(:employee))
  end

  test "should destroy employee" do
    assert_difference('Employee.count', -1) do
      delete :destroy, id: @employee
    end

    assert_redirected_to employees_path
  end
end
