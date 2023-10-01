require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should vote for' do
    sign_in accounts 'admin_0'

    $redis.del "nodes/#{nodes(:one).id}/votes/#{accounts('admin_0').id}"
    assert_difference 'nodes(:one).score' do
      post vote_for_node_url nodes(:one)
      assert_nil flash[:alert]
      nodes(:one).reload
    end
    assert_redirected_to user_diary_url users('visitor_1'), nodes(:one).content
  end

  test 'should not be allowed to vote for' do
    sign_in accounts 'visitor_0'
    assert_no_difference 'nodes(:one).score' do
      post vote_for_node_url nodes(:one)
      assert_nil flash[:alert]
    end
    assert_redirected_to user_diary_url users('visitor_1'), nodes(:one).content
  end

  test 'should vote against' do
    sign_in accounts 'admin_0'

    $redis.del "nodes/#{nodes(:one).id}/votes/#{accounts('admin_0').id}"
    assert_difference 'nodes(:one).score', -1 do
      post vote_against_node_url nodes(:one)
      assert_nil flash[:alert]
      nodes(:one).reload
    end
    assert_redirected_to user_diary_url users('visitor_1'), nodes(:one).content
  end

  test 'should not be allowed to vote against' do
    sign_in accounts 'visitor_0'

    assert_no_difference 'nodes(:one).score', -1 do
      post vote_against_node_url nodes(:one)
      assert_nil flash[:alert]
    end
    assert_redirected_to user_diary_url users('visitor_1'), nodes(:one).content
  end
end
