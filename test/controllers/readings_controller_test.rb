require 'test_helper'

class ReadingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should list readings' do
    sign_in accounts 'visitor_0'
    get readings_url
    assert_response :success
  end

  test 'should destroy reading' do
    sign_in accounts 'visitor_0'
    delete reading_url nodes(:one)
    assert_redirected_to user_diary_url users('visitor_1'), nodes(:one).content
  end

  test 'should destroy all readings' do
    sign_in accounts 'visitor_0'
    delete readings_url
    assert_redirected_to readings_url
  end
end
