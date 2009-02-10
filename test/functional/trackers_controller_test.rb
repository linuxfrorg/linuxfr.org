require 'test_helper'

class TrackersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trackers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tracker" do
    assert_difference('Tracker.count') do
      post :create, :tracker => { }
    end

    assert_redirected_to tracker_path(assigns(:tracker))
  end

  test "should show tracker" do
    get :show, :id => trackers(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => trackers(:one).id
    assert_response :success
  end

  test "should update tracker" do
    put :update, :id => trackers(:one).id, :tracker => { }
    assert_redirected_to tracker_path(assigns(:tracker))
  end

  test "should destroy tracker" do
    assert_difference('Tracker.count', -1) do
      delete :destroy, :id => trackers(:one).id
    end

    assert_redirected_to trackers_path
  end
end
