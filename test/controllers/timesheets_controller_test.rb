require 'test_helper'

class TimesheetsControllerTest < ActionController::TestCase
  setup do
    @timesheet = timesheets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:timesheets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create timesheet" do
    assert_difference('Timesheet.count') do
      post :create, timesheet: { employee: @timesheet.employee, hours: @timesheet.hours }
    end

    assert_redirected_to timesheet_path(assigns(:timesheet))
  end

  test "should xshow timesheet" do
    get :xshow, id: @timesheet
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @timesheet
    assert_response :success
  end

  test "should update timesheet" do
    patch :update, id: @timesheet, timesheet: { employee: @timesheet.employee, hours: @timesheet.hours }
    assert_redirected_to timesheet_path(assigns(:timesheet))
  end

  test "should destroy timesheet" do
    assert_difference('Timesheet.count', -1) do
      delete :destroy, id: @timesheet
    end

    assert_redirected_to timesheets_path
  end
end
