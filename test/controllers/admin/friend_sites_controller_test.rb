require 'test_helper'

class FriendSitesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'admin_0'
  end

  test 'should list friend sites' do
    get admin_friend_sites_url

    assert_response :success
  end

  test 'should get new' do
    get new_admin_friend_site_url

    assert_response :success
  end

  test 'should create friend site' do
    assert_difference('FriendSite.count') do
      post admin_friend_sites_url, params: {
        friend_site: {
          title: 'hello world my friend site',
          url: 'http://example.com'
        }
      }

      assert flash[:notice]
    end
    assert_response :redirect
  end

  test 'should not create friend site' do
    assert_no_difference('FriendSite.count') do
      post admin_friend_sites_url, params: {
        friend_site: {
          url: 'http://example.com'
        }
      }

      assert flash[:alert]
    end
    assert_response :success
  end

  test 'should get edit' do
    get edit_admin_friend_site_url(friend_sites(:one))

    assert_response :success
  end

  test 'should update friend site' do
    patch admin_friend_site_url(friend_sites(:one)), params: {
      friend_site: {
        title: 'hello world my friend site',
        url: 'http://example.com'
      }
    }

    assert flash[:notice]
    assert_response :redirect
  end

  test 'should not update friend site' do
    patch admin_friend_site_url(friend_sites(:one)), params: {
      friend_site: {
        title: ''
      }
    }

    assert flash[:alert]
    assert_response :success
  end

  test 'should destroy friend site' do
    assert_difference('FriendSite.count', -1) do
      delete admin_friend_site_url(friend_sites(:one))

      assert flash[:notice]
    end
    assert_response :redirect
  end

  test 'should lower friend site' do
    assert_difference('friend_sites(:one).reload.position') do
      post lower_admin_friend_site_url(friend_sites(:one))

      assert_nil flash[:alert]
    end
    assert_response :redirect
  end

  test 'should higher friend site' do
    assert_no_difference('friend_sites(:one).position') do
      post higher_admin_friend_site_url(friend_sites(:one))

      assert_nil flash[:alert]
    end
    assert_response :redirect
  end
end
