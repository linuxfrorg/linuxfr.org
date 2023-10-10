require "test_helper"

class SectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sections_url

    assert_response :success
  end

  test "should show section" do
    get section_url sections :default

    assert_response :success
  end
end
