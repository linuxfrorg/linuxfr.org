require 'test_helper'

class ForumsControllerTest < ActionDispatch::IntegrationTest
  test 'get index' do
    get forums_url
    assert_response :success
  end

  test 'get show' do
    get forum_url(forums(:one), format: :html)
    assert_response :success
    assert_nil flash[:alert]
  end
end
