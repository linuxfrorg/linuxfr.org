require 'test_helper'

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should list bookmarks' do
    get bookmarks_url

    assert_response :success
  end

  test 'should show bookmark' do
    sign_in accounts 'admin_0'
    get user_bookmark_url(users('visitor_0'), bookmarks(:one), format: :html)

    assert_response :success
    assert_nil flash[:alert]
  end

  test 'should not find bookmark' do
    get user_bookmark_url(users('visitor_1'), bookmarks(:one), format: :html)

    assert_redirected_to user_bookmark_url(users('visitor_0'), Bookmark.last)
  end

  test 'should get new' do
    sign_in accounts 'visitor_0'
    get new_bookmark_url

    assert_response :success
  end

  test 'should preview bookmark' do
    sign_in accounts 'visitor_0'
    assert_no_difference('Bookmark.count') do
      post bookmarks_url,
           params: {
             bookmark: {
               title: 'Hello world',
               link: 'http://example.com'
             },
             tags: 'foo, bar',
             commit: 'Prévisualiser'
           }
    end
    assert_response :success
  end

  test 'should create bookmark' do
    sign_in accounts 'visitor_0'
    assert_difference('Bookmark.count') do
      post bookmarks_url,
           params: {
             bookmark: {
               title: 'Hello world',
               link: 'http://example.com',
               lang: 'fr'
             },
             tags: 'foo, bar'
           }
    end
    assert_redirected_to user_bookmark_url(users('visitor_0'), Bookmark.last)
  end

  test 'should get edit' do
    sign_in accounts 'admin_0'
    get edit_user_bookmark_url(users('visitor_0'), bookmarks(:one))

    assert_response :success
  end

  test 'should preview update' do
    sign_in accounts 'admin_0'
    patch user_bookmark_url(users('visitor_0'), bookmarks(:one)),
          params: {
            bookmark: {
              link: 'http://example.com'
            },
            commit: 'Prévisualiser'
          }

    assert_response :success
  end

  test 'should update bookmark' do
    sign_in accounts 'admin_0'
    patch user_bookmark_url(users('visitor_0'), bookmarks(:one)),
          params: {
            bookmark: {
              link: 'http://example.com'
            }
          }

    assert_redirected_to user_bookmark_url(users('visitor_0'), bookmarks(:one))
  end

  test 'should not update bookmark' do
    sign_in accounts 'admin_0'
    patch user_bookmark_url(users('visitor_0'), bookmarks(:one)),
          params: {
            bookmark: {
              title: ''
            }
          }

    assert_response :success
  end

  test 'should destroy bookmark' do
    sign_in accounts 'admin_0'
    delete user_bookmark_url(users('visitor_0'), bookmarks(:one))

    assert_redirected_to bookmarks_url
  end
end
