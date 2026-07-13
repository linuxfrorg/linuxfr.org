require "test_helper"

class Admin::StylesheetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "admin_0"
  end

  test "should show stylesheet" do
    get admin_stylesheet_url

    assert_response :success
  end

  test "should create stylesheet" do
    # Tant qu'il manque un phantomjs de test
    assert_raises NoMethodError do
      post admin_stylesheet_url, params: {
        url: "https://linuxfr.org/test"
      }
    end
  end
end
