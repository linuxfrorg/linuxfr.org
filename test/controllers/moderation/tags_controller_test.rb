require 'test_helper'

class Moderation::TagsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'moderator_0'
  end

  test 'should list tags' do
    get moderation_tags_url

    assert_response :success
  end
end
