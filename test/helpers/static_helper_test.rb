require "test_helper"

class StaticHelperTest < ActionView::TestCase
  include UsersHelper

  def current_account
    accounts "visitor_0"
  end

  test "should helperify" do
    assert_match "admin_0", helperify("{{admin_list}}")
  end

  test "should return admin list" do
    assert_match "admin_0", helper_admin_list
  end

  test "should return editor list" do
    assert_match "editor_0", helper_editor_list
  end

  test "should return moderator list" do
    assert_match "moderator_0", helper_moderator_list
  end

  test "should return maintainer list" do
    assert_match "maintainer_0", helper_maintainer_list
  end

  test "should return friend sites list" do
    assert_match "people-list", helper_friend_sites_list
  end

  test "should return responses list" do
    assert_match "MyText", helper_responses_list
  end
end
