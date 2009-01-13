require 'test_helper'

class SectionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create section" do
    assert_difference('Section.count') do
      post :create, :section => { }
    end

    assert_redirected_to section_path(assigns(:section))
  end

  test "should show section" do
    get :show, :id => sections(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => sections(:one).id
    assert_response :success
  end

  test "should update section" do
    put :update, :id => sections(:one).id, :section => { }
    assert_redirected_to section_path(assigns(:section))
  end

  test "should destroy section" do
    assert_difference('Section.count', -1) do
      delete :destroy, :id => sections(:one).id
    end

    assert_redirected_to sections_path
  end
end
