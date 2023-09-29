require 'test_helper'

class TrackersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in accounts 'admin_0'
  end

  test 'should get index' do
    get trackers_url
    assert_response :success
  end

  test 'should get new' do
    get new_tracker_url
    assert_response :success
  end

  test 'should create tracker' do
    assert_difference('Tracker.count') do
      post trackers_url, params: {
        tracker: {
          title: 'hello world my tracker',
          body: 'hello world',
          wiki_body: 'hello world',
          category_id: categories(:one).id
        }
      }
      assert_nil flash[:alert]
      assert flash[:notice]
    end

    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select 'a', 'hello world my tracker'
  end

  test 'should show tracker' do
    get trackers_url(trackers(:one), format: :html)
    assert_response :success
  end

  test 'should get edit' do
    get edit_tracker_url(trackers(:one))
    assert_response :success
  end

  test 'should update tracker' do
    patch tracker_url(trackers(:two)), params: {
      tracker: {
        title: 'new title'
      }
    }
    assert_nil flash[:alert]
    assert flash[:notice]

    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select 'a', 'new title'
  end

  test 'should list comments' do
    get comments_trackers_url format: :atom
    assert_response :success
  end

  test 'should destroy tracker' do
    # Deleting a tracker ends up as an invisible node
    assert_difference('Node.visible.count', -1) do
      delete tracker_url(trackers(:one))
    end

    assert_redirected_to trackers_path
  end
end
