require "test_helper"

class Moderation::PollControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "moderator_0"
  end

  test "should list polls" do
    get moderation_polls_url

    assert_response :success
  end

  test "should show poll" do
    comments("poll_2").parent_id = comments(:poll).id
    comments("poll_2").generate_materialized_path
    get moderation_poll_url(polls(:one))

    assert_response :success
  end

  test "should accept poll" do
    # For information, there can only be one published poll!
    assert_difference("Poll.draft.count", -1) do
      post accept_moderation_poll_url(polls(:draft))

      assert flash[:notice]
    end
    assert_redirected_to poll_url polls(:draft)
  end

  test "should refuse poll" do
    assert_difference("Poll.draft.count", -1) do
      post refuse_moderation_poll_url(polls(:draft))

      assert flash[:notice]
    end
    assert_redirected_to moderation_polls_url
  end

  test "should get edit" do
    get edit_moderation_poll_url(polls(:one))

    assert_response :success
  end

  test "should update poll" do
    patch moderation_poll_url(polls(:one)), params: {
      poll: {
        title: "hello world my poll"
      }
    }

    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to moderation_poll_url(polls(:one).reload)
  end

  test "should not update poll" do
    patch moderation_poll_url(polls(:one)), params: {
      poll: {
        title: ""
      }
    }

    assert flash[:alert]
    assert_nil flash[:notice]
    assert_response :success
  end

  test "should set poll on ppp" do
    post ppp_moderation_poll_url(polls(:one))

    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to root_url

    # Reset
    Redis.new.del("nodes/ppp")
  end
end
