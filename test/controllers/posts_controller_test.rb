require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should list posts' do
    get forum_posts_url forums(:one)

    assert_redirected_to forum_url forums :one
  end

  test 'should show post' do
    get forum_post_url(forums(:one), posts(:one))

    assert_response :success
  end

  test 'should show post when logged in' do
    sign_in accounts 'visitor_0'
    get forum_post_url(forums(:one), posts(:one))

    assert_response :success
  end

  test 'should show post from another forum' do
    get forum_post_url(forums(:two), posts(:one))

    assert_redirected_to forum_post_url forums(:one), posts(:one)
  end

  test 'should get new page' do
    sign_in accounts 'maintainer_0'
    get new_post_url forums(:one)

    assert_response :success
  end

  test 'should preview create' do
    sign_in accounts 'maintainer_0'
    assert_no_difference 'Post.count' do
      post posts_url(forums(:one)), params: {
        post: {
          forum_id: forums(:one).id,
          title: 'Hello world',
          body: 'Hello world',
          wiki_body: 'Hello world'
        },
        tags: 'hello, world',
        commit: 'Prévisualiser'
      }

      assert_nil flash[:alert]
    end
    assert_response :success
  end

  test 'should create post' do
    sign_in accounts 'maintainer_0'
    assert_difference 'Post.count' do
      post posts_url(forums(:one)), params: {
        post: {
          forum_id: forums(:one).id,
          title: 'Hello world',
          body: 'Hello world',
          wiki_body: 'Hello world'
        },
        tags: 'hello, world'
      }

      assert flash[:notice]
    end
    assert_redirected_to forum_posts_url forums :one
  end

  test 'should get edit page' do
    sign_in accounts 'admin_0'
    get edit_forum_post_url forums(:one), posts(:one)

    assert_response :success
  end

  test 'should preview update' do
    sign_in accounts 'admin_0'
    assert_no_difference 'Post.count' do
      patch forum_post_url(forums(:one), posts(:one)), params: {
        post: {
          forum_id: forums(:one).id,
          title: 'Hello world',
          body: 'Hello world',
          wiki_body: 'Hello world'
        },
        tags: 'hello, world',
        commit: 'Prévisualiser'
      }

      assert_nil flash[:alert]
    end
    assert_response :success
  end

  test 'should update post' do
    sign_in accounts 'admin_0'
    patch forum_post_url(forums(:one), posts(:one)), params: {
      post: {
        title: 'Updated',
        body: 'Updated',
        wiki_body: 'Updated'
      },
      tags: 'updated'
    }

    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to forum_posts_url forums :one
  end

  test 'should destroy post' do
    sign_in accounts 'admin_0'
    assert_difference('Post.all.find_all { |d| d.visible? }.count', -1) do
      delete forum_post_url(forums(:one), posts(:one))

      assert flash[:notice]
    end
    assert_redirected_to forum_posts_url forums :one
  end
end
