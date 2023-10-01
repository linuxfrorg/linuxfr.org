require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should list comments' do
    get node_comments_url(nodes(:tracker_one))
    assert_response :success
  end

  test 'should show comment' do
    get node_comment_url(nodes(:tracker_one), comments(:one))
    assert_response :success
  end

  test 'should get new' do
    sign_in accounts 'visitor_0'

    get new_node_comment_url(comments(:one).node, comments(:one))
    assert_response :success
  end

  test 'should not get new for blocked user' do
    sign_in accounts 'visitor_666'
    accounts('visitor_666').block 1, accounts('admin_0').user.id

    get new_node_comment_url(comments(:one).node, comments(:one))

    assert_redirected_to tracker_url trackers(:one).cached_slug
  end

  test 'should not get new on old content' do
    sign_in accounts 'visitor_0'

    get new_node_comment_url(comments(:old).node, comments(:old))

    assert_redirected_to user_diary_path users('visitor_1'), comments(:old).content.cached_slug
  end

  test 'should answer' do
    sign_in accounts 'visitor_0'

    get answer_node_comment_url(comments(:one).node, comments(:one))
    assert_response :success
  end

  test 'should preview comment' do
    sign_in accounts 'visitor_0'

    assert_no_difference('Comment.count') do
      post node_comments_url(comments(:one).node),
           params: {
             comment: {
               node_id: comments(:one).node.id,
               title: 'Hello world',
               wiki_body: 'This is a comment'
             },
             commit: 'Prévisualiser'
           }
    end
    assert_response :success
  end

  test 'should create comment' do
    sign_in accounts 'visitor_0'

    assert_difference('Comment.count') do
      post node_comments_url(comments(:one).node),
           params: {
             comment: {
               node_id: comments(:one).node.id,
               title: 'Hello world',
               wiki_body: 'This is a comment'
             }
           }
      assert_nil flash[:alert]
      assert flash[:notice]
    end
    assert_redirected_to tracker_url(trackers(:one).cached_slug) + "#comment-#{Comment.last.id}"
  end

  test 'should not edit old comment' do
    sign_in accounts 'visitor_10'

    get edit_node_comment_url(comments(:old).node, comments(:old))
    assert_response :forbidden
  end

  test 'should edit comment' do
    sign_in accounts 'admin_0'

    get edit_node_comment_url(comments(:one).node, comments(:one))
    assert_response :success
  end

  test 'should preview update comment' do
    # skip 'trouble with wikification'
    sign_in accounts 'admin_0'

    patch node_comment_url(comments(:one).node, comments(:one)),
          params: {
            comment: {
              title: 'Updated comment',
              wiki_body: 'This is an updated comment'
            },
            commit: 'Prévisualiser'
          }
    assert_response :success
  end

  test 'should update comment' do
    # skip 'trouble with wikification'
    sign_in accounts 'admin_0'

    patch node_comment_url(comments(:one).node, comments(:one)),
          params: {
            comment: {
              title: 'Updated comment',
              wiki_body: 'This is an updated comment'
            }
          }
    assert_redirected_to tracker_url(trackers(:one).cached_slug) + "#comment-#{comments(:one).id}"
  end

  test 'should destroy comment' do
    sign_in accounts 'admin_0'

    assert_difference('Comment.published.count', -1) do
      delete node_comment_url(comments(:one).node, comments(:one))
      assert_not flash[:alert]
      assert flash[:notice]
    end
    assert_redirected_to tracker_url(trackers(:one).cached_slug)
  end

  test 'should redirect for templeet' do
    sign_in accounts 'visitor_0'

    get "/comments/#{comments(:one).id}"
    assert_redirected_to node_comment_url(comments(:one).node, comments(:one))
  end
end
