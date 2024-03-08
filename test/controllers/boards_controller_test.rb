require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should show" do
    get board_url(Board.free, format: :html)

    assert_response :success
  end

  test "should create" do
    sign_in accounts "maintainer_0"

    post board_url, params: {
      board: {
        object_type: "Free",
        message: "Hello"
      }
    }

    assert_response :redirect
  end

  test "should create with js" do
    sign_in accounts "maintainer_0"

    post board_url, params: {
      board: {
        object_type: "Free",
        message: "Hello"
      }
    }, xhr: true

    assert_response :success
  end
end
