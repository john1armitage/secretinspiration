require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @page = pages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create page" do
    assert_difference('Page.count') do
      post :create, page: { body: @page.body, credit: @page.credit, publish: @page.publish, release: @page.release, sub: @page.sub, title: @page.title, topic_id_id: @page.topic_id_id, user_id: @page.user_id }
    end

    assert_redirected_to page_path(assigns(:page))
  end

  test "should xshow page" do
    get :xshow, id: @page
    assert_response :success
  end

  test "should get edit" do
    get :form, id: @page
    assert_response :success
  end

  test "should update page" do
    patch :update, id: @page, page: { body: @page.body, credit: @page.credit, publish: @page.publish, release: @page.release, sub: @page.sub, title: @page.title, topic_id_id: @page.topic_id_id, user_id: @page.user_id }
    assert_redirected_to page_path(assigns(:page))
  end

  test "should destroy page" do
    assert_difference('Page.count', -1) do
      delete :destroy, id: @page
    end

    assert_redirected_to pages_path
  end
end
