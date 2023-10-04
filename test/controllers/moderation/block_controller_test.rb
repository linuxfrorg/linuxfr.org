require 'test_helper'

class Moderation::BlockControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'moderator_0'
  end

  test 'should block account' do
    post moderation_block_index_url, params: {
      account_id: accounts('visitor_0').id
    }

    assert_nil flash[:alert]
    assert_predicate accounts('visitor_0'), :blocked?
    assert_response :success
  end

  test 'should unblock account' do
    post moderation_block_index_url, params: {
      account_id: accounts('visitor_0').id,
      nb_days: 0
    }

    assert_nil flash[:alert]
    assert_not accounts('visitor_0').blocked?
    assert_response :success
  end
end
