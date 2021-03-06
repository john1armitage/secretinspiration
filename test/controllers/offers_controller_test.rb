require 'test_helper'

class OffersControllerTest < ActionController::TestCase
  setup do
    @offer = offers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:offers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create offer" do
    assert_difference('Offer.count') do
      post :create, offer: { amount: @offer.amount, days: @offer.days, desc: @offer.desc, live: @offer.live, name: @offer.name, notes: @offer.notes, offer_type: @offer.offer_type }
    end

    assert_redirected_to offer_path(assigns(:offer))
  end

  test "should xshow offer" do
    get :xshow, id: @offer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @offer
    assert_response :success
  end

  test "should update offer" do
    patch :update, id: @offer, offer: { amount: @offer.amount, days: @offer.days, desc: @offer.desc, live: @offer.live, name: @offer.name, notes: @offer.notes, offer_type: @offer.offer_type }
    assert_redirected_to offer_path(assigns(:offer))
  end

  test "should destroy offer" do
    assert_difference('Offer.count', -1) do
      delete :destroy, id: @offer
    end

    assert_redirected_to offers_path
  end
end
