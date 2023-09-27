require 'test_helper'

class StaticControllerTest < ActionDispatch::IntegrationTest
  test 'should get home page' do
    get static_url pages(:one)
    assert_response :success
  end

  test 'get changelog' do
    get changelog_url pages(:one)
    assert_response :success
  end
end
