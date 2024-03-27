require "test_helper"

class Admin::ApplicationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "admin_0"
  end

  test "should list applications" do
    get admin_applications_url

    assert_response :success
  end

  test "should not update application" do
    patch admin_application_url(Doorkeeper::Application.first), params: {
      doorkeeper_application: { name: "New name" }
    }

    assert_response :success
  end

  test "should update application" do
    app = Doorkeeper::Application.first
    app.owner = accounts("admin_0")
    app.save!

    patch admin_application_url(app), params: {
      doorkeeper_application: { name: "New name" }
    }

    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to admin_applications_url
  end

  test "should destroy application" do
    assert_difference("Doorkeeper::Application.count", -1) do
      delete admin_application_url(Doorkeeper::Application.first)
    end
    assert_redirected_to admin_applications_url
  end
end
