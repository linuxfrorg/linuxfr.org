require 'test_helper'

class ModerationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should get index' do
    sign_in accounts 'admin_0'

    get moderation_url
    assert_redirected_to moderation_news_index_url
  end
end
