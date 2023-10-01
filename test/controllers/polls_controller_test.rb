require 'test_helper'

class PollsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should get index' do
    get polls_url
    assert_response :success
  end

  test 'should get show' do
    sign_in accounts 'maintainer_0'
    get poll_url polls(:one), format: :html
    assert_response :success
  end

  test 'should get new page' do
    sign_in accounts 'maintainer_0'
    get new_poll_url
    assert_response :success
  end

  test 'should preview creation' do
    sign_in accounts 'maintainer_0'
    assert_no_difference('Poll.count') do
      post polls_url, params: {
        poll: {
          title: 'Hello world',
          wiki_explanations: 'Partie première',
          answers_attributes: {
            '0' => {
              answer: 'Hello world'
            }
          }
        },
        commit: 'Prévisualiser'
      }
      assert_nil flash[:alert]
    end
    assert_response :success
  end

  test 'should create poll' do
    sign_in accounts 'maintainer_0'

    assert_difference('Poll.count') do
      post polls_url, params: {
        poll: {
          title: 'Hello world',
          wiki_explanations: 'Partie première',
          answers_attributes: {
            '0' => {
              answer: 'Hello world'
            }
          }
        }
      }
      assert_nil flash[:alert]
      assert flash[:notice]
    end
    assert_redirected_to polls_url
  end

  test 'should vote' do
    # Remove eventual existing vote
    $redis.del "polls/#{polls(:one).id}/127.0.0.1"
    sign_in accounts :joe

    post vote_poll_url polls(:one), position: 0
    assert_nil flash[:alert]
    assert flash[:notice]

    assert_redirected_to poll_url polls(:one)
  end

  test 'should not vote' do
    # Remove eventual existing vote
    $redis.del "polls/#{polls(:one).id}/127.0.0.1"
    sign_in accounts :joe

    post vote_poll_url polls(:one)
    assert flash[:alert]
    assert_nil flash[:notice]

    assert_redirected_to poll_url polls(:one)
  end
end
