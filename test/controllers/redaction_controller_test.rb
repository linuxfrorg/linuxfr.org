require 'test_helper'

class RedactionControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get redaction_url
    assert_response :success
  end
end
