require "test_helper"

class RelevancesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should vote for" do
    sign_in accounts "visitor_0"
    Redis.new.del "comments/#{comments(:one).id}/votes/for", accounts("visitor_0").id

    assert_difference "comments(:one).nb_votes_for" do
      post relevance_for_node_comment_url nodes(:tracker_one), comments(:one), format: :json

      assert_nil flash[:alert]
    end

    assert_response :success
  end

  test "should vote against" do
    sign_in accounts "visitor_2"
    Redis.new.del "comments/#{comments(:one).id}/votes/against", accounts("visitor_2").id

    assert_difference "comments(:one).nb_votes_against" do
      post relevance_against_node_comment_url nodes(:tracker_one), comments(:one), format: :json

      assert_nil flash[:alert]
    end

    assert_response :success
  end

  test "should not vote for" do
    sign_in accounts "visitor_10"

    assert_no_difference "comments(:one).nb_votes_for" do
      post relevance_for_node_comment_url nodes(:tracker_one), comments(:one), format: :json

      assert_nil flash[:alert]
    end

    assert_response :success
  end

  test "should not vote against" do
    sign_in accounts "visitor_10"

    assert_no_difference "comments(:one).nb_votes_against" do
      post relevance_against_node_comment_url nodes(:tracker_one), comments(:one), format: :json

      assert_nil flash[:alert]
    end

    assert_response :success
  end
end
