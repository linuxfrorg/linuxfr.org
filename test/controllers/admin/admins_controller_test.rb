require "test_helper"

class Admin::AdminsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "admin_0"
  end

  test "should create admin" do
    post admin_account_admin_url(accounts("visitor_0"))

    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to accounts("visitor_0").user
  end

  test "should destroy admin" do
    delete admin_account_admin_url(accounts("admin_0"))

    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to accounts("admin_0").user
  end
end
