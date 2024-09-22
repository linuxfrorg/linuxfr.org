require "test_helper"

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get tracker" do
    get statistiques_tracker_url

    assert_response :success
  end

  test "should get prizes" do
    get statistiques_prizes_url

    assert_response :success
  end

  test "should get users" do
    get statistiques_users_url

    assert_response :success
  end

  test "should get anonymous" do
    get statistiques_anonymous_url

    assert_response :success
  end

  test "should get collective" do
    get statistiques_collective_url

    assert_response :success
  end

  test "should get top" do
    get statistiques_top_url

    assert_response :success
  end

  test "should get moderation" do
    get statistiques_moderation_url

    assert_response :success
  end

  test "should get redaction" do
    get statistiques_redaction_url

    assert_response :success
  end

  test "should get contents" do
    get statistiques_contents_url

    assert_response :success
  end

  test "should get comments" do
    get statistiques_comments_url

    assert_response :success
  end

  test "should get tags" do
    get statistiques_tags_url

    assert_response :success
  end

  test "should get applications" do
    get statistiques_applications_url

    assert_response :success
  end
end
