require 'test_helper'

class Admin::LogosControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'admin_0'
  end

  test 'should show logo' do
    get admin_logo_url

    assert_response :success
  end

  test 'should create logo' do
    post admin_logo_url, params: {
      logo: fixture_file_upload('Logo.png', 'image/png')
    }

    assert flash[:notice]
    assert_redirected_to admin_logo_url
  end
end
