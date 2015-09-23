require 'test_helper'

class BookingsControllerTest < ActionController::TestCase
  setup do
    @booking = bookings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bookings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts booking" do
    assert_difference('Booking.count') do
      post :carts, booking: { arrival: @booking.arrival, customer_id: @booking.customer_id, notes: @booking.notes, pax: @booking.pax, state: @booking.state, user_id: @booking.user_id }
    end

    assert_redirected_to booking_path(assigns(:booking))
  end

  test "should xshow booking" do
    get :xshow, id: @booking
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @booking
    assert_response :success
  end

  test "should update booking" do
    patch :update, id: @booking, booking: { arrival: @booking.arrival, customer_id: @booking.customer_id, notes: @booking.notes, pax: @booking.pax, state: @booking.state, user_id: @booking.user_id }
    assert_redirected_to booking_path(assigns(:booking))
  end

  test "should destroy booking" do
    assert_difference('Booking.count', -1) do
      delete :destroy, id: @booking
    end

    assert_redirected_to bookings_path
  end
end
