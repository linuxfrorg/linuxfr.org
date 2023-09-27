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
    account = accounts('maintainer_0')
    account.confirm
    sign_in account

    get new_node_comment_url(comments(:one).node, comments(:one))
    assert_response :success
  end

  test 'should answer' do
    account = accounts('maintainer_0')
    account.confirm
    sign_in account

    get answer_node_comment_url(comments(:one).node, comments(:one))
    assert_response :success
  end

  test 'should preview comment' do
    account = accounts('maintainer_0')
    account.confirm
    sign_in account
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
    account = accounts('maintainer_0')
    account.confirm
    sign_in account
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

  test 'should edit comment' do
    account = accounts('admin_0')
    account.confirm
    sign_in account
    get edit_node_comment_url(comments(:one).node, comments(:one))
    assert_response :success
  end

  test 'should preview update comment' do
    # skip 'trouble with wikification'
    account = accounts('admin_0')
    account.confirm
    sign_in account

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
    account = accounts('admin_0')
    account.confirm
    sign_in account

    patch node_comment_url(comments(:one).node, comments(:one)),
          params: {
            comment: {
              title: 'Updated comment',
              wiki_body: 'This is an updated comment'
            }
          }
    assert_redirected_to tracker_url(trackers(:one).cached_slug) + "#comment-#{Comment.last.id}"
  end

  test 'should destroy comment' do
    account = accounts('admin_0')
    account.confirm
    sign_in account

    assert_difference('Comment.published.count', -1) do
      delete node_comment_url(comments(:one).node, comments(:one))
      assert_not flash[:alert]
      assert flash[:notice]
    end
    assert_redirected_to tracker_url(trackers(:one).cached_slug)
  end
end
