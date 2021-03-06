require 'test_helper'

class PicsControllerTest < ActionController::TestCase
  setup do
    @pic = pics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should carts pic" do
    assert_difference('Pic.count') do
      post :carts, pic: { image: @pic.image, name: @pic.name, viewable_id: @pic.viewable_id, viewable_type: @pic.viewable_type }
    end

    assert_redirected_to pic_path(assigns(:pic))
  end

  test "should xshow pic" do
    get :xshow, id: @pic
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @pic
    assert_response :success
  end

  test "should update pic" do
    patch :update, id: @pic, pic: { image: @pic.image, name: @pic.name, viewable_id: @pic.viewable_id, viewable_type: @pic.viewable_type }
    assert_redirected_to pic_path(assigns(:pic))
  end

  test "should destroy pic" do
    assert_difference('Pic.count', -1) do
      delete :destroy, id: @pic
    end

    assert_redirected_to pics_path
  end
end
