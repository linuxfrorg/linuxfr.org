require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "visitor_0"
  end

  test "should list comments" do
    get node_comments_url(nodes(:tracker_one))

    assert_response :success
  end

  test "should show comment" do
    get node_comment_url(nodes(:tracker_one), comments(:one))

    assert_response :success
  end

  test "should get new" do
    get new_node_comment_url(comments(:one).node, comments(:one))

    assert_response :success
  end

  test "should not get new" do
    get new_node_comment_url(comments(:old).node, comments(:old))

    assert_redirected_to user_diary_url diaries(:old).user, diaries(:old)

    # Blocked account
    sign_in accounts "visitor_666"
    accounts("visitor_666").block 1, accounts("admin_0").user.id

    get new_node_comment_url(comments(:one).node, comments(:one))

    assert_redirected_to tracker_url trackers(:one).cached_slug
  end

  test "should start answer" do
    get answer_node_comment_url(comments(:one).node, comments(:one))

    assert_response :success
  end

  test "should preview comment" do
    assert_no_difference "Comment.count" do
      post node_comments_url(comments(:one).node), params: {
        comment: {
          node_id: comments(:one).node.id,
          title: "Hello world",
          wiki_body: "This is a comment"
        },
        commit: "Prévisualiser"
      }

      assert_nil flash[:alert]
    end
    assert_response :success
  end

  test "should create comment" do
    assert_difference "Comment.count" do
      post node_comments_url(comments(:one).node), params: {
        comment: {
          node_id: comments(:one).node.id,
          title: "Hello world",
          wiki_body: "This is a comment"
        }
      }

      assert flash[:notice]
    end
    assert_redirected_to tracker_url(trackers(:one).cached_slug) + "#comment-#{Comment.last.id}"
  end

  test "should not edit old comment" do
    sign_in accounts "visitor_10"

    get edit_node_comment_url(comments(:old).node, comments(:old))

    assert_response :forbidden
  end

  test "should edit comment" do
    sign_in accounts "admin_0"

    get edit_node_comment_url(comments(:one).node, comments(:one))

    assert_response :success
  end

  test "should preview update comment" do
    # skip 'trouble with wikification'
    sign_in accounts "admin_0"

    patch node_comment_url(comments(:one).node, comments(:one)), params: {
      comment: { title: "Updated comment" },
      commit: "Prévisualiser"
    }

    assert_nil flash[:alert]
    assert_response :success
  end

  test "should update comment" do
    # skip 'trouble with wikification'
    sign_in accounts "admin_0"

    patch node_comment_url(comments(:one).node, comments(:one)), params: {
      comment: { title: "Updated comment" }
    }

    assert_nil flash[:alert]
    assert_redirected_to tracker_url(trackers(:one).cached_slug) + "#comment-#{comments(:one).id}"
  end

  test "should destroy comment" do
    sign_in accounts "admin_0"

    assert_difference "Comment.published.count", -1 do
      delete node_comment_url(comments(:one).node, comments(:one))

      assert flash[:notice]
    end
    assert_redirected_to tracker_url(trackers(:one).cached_slug)
  end

  test "should redirect for templeet" do
    get "/comments/#{comments(:one).id}"

    assert_redirected_to node_comment_url(comments(:one).node, comments(:one))
  end
end
