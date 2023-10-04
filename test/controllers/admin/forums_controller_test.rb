require 'test_helper'

class Admin::ForumsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'admin_0'
  end

  test 'should list forums' do
    get admin_forums_url

    assert_response :success
  end

  test 'should get new' do
    get new_admin_forum_url

    assert_response :success
  end

  test 'should not create forum' do
    assert_no_difference('Forum.count') do
      post admin_forums_url, params: {
        forum: { title: '' }
      }
    end
    assert_response :success
  end

  test 'should create forum' do
    assert_difference('Forum.count') do
      post admin_forums_url, params: {
        forum: {
          title: 'Hello world',
          cached_slug: 'hello-world'
        }
      }

      assert flash[:notice]
    end
    assert_redirected_to admin_forums_url
  end

  test 'should get edit' do
    get edit_admin_forum_url(forums(:one))

    assert_response :success
  end

  test 'should not update forum' do
    patch admin_forum_url(forums(:one)), params: {
      forum: { title: '' }
    }

    assert_response :success
  end

  test 'should update forum' do
    patch admin_forum_url(forums(:one)), params: {
      forum: { title: 'Hello world' }
    }

    assert flash[:notice]
    assert_redirected_to admin_forums_url
  end

  test 'should archive forum' do
    assert_difference 'Forum.active.count', -1 do
      post archive_admin_forum_url(forums(:one))

      assert flash[:notice]
    end
    assert_redirected_to admin_forums_url
  end

  test 'should reopen forum' do
    post reopen_admin_forum_url(forums(:one))

    assert flash[:notice]

    assert_redirected_to admin_forums_url
  end

  test 'should destroy forum' do
    assert_difference 'Forum.count', -1 do
      delete admin_forum_url(forums(:two))

      assert flash[:notice]
    end
    assert_redirected_to admin_forums_url
  end

  test 'should lower forum' do
    assert_difference 'forums(:two).reload.position', -1 do
      post lower_admin_forum_url forums(:one)
    end
    assert_redirected_to admin_forums_url
  end

  test 'should higher forum' do
    assert_difference 'forums(:one).reload.position', 1 do
      post higher_admin_forum_url forums(:two)
    end
    assert_redirected_to admin_forums_url
  end
end
