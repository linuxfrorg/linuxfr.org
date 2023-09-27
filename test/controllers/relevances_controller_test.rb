require 'test_helper'

class RelevancesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should vote for' do
    sign_in accounts 'admin_1'

    post relevance_for_node_comment_url nodes(:tracker_one), comments(:one), format: :json

    assert_response :success
  end

  test 'should vote against' do
    sign_in accounts 'admin_1'

    post relevance_against_node_comment_url nodes(:tracker_one), comments(:one), format: :json

    assert_response :success
  end
end
