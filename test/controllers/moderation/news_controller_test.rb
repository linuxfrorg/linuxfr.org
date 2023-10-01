require 'test_helper'

class Moderation::NewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'moderator_0'
  end

  test 'should list news' do
    get moderation_news_index_url
    assert_response :success
  end

  test 'should show news' do
    get moderation_news_url news(:draft)
    assert_response :success
  end

  test 'should get edit page' do
    get edit_moderation_news_url news(:draft)
    assert_response :success
  end

  test 'should update news' do
    patch moderation_news_url news(:draft), params: {
      news: {
        wiki_body: 'Hello world'
      },
      tags: 'test'
    }
    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to news_url news(:draft)
  end

  test 'should update news as xhr' do
    patch moderation_news_url(news(:draft)), params: {
      news: {
        wiki_body: 'Hello world'
      },
      tags: 'test'
    }, xhr: true
    assert_nil flash[:alert]
    assert_response :success
  end

  test 'should not accept locked news' do
    sign_in accounts 'admin_0'

    news(:candidate).lock_by users('visitor_0')
    assert_no_difference 'News.candidate.count' do
      post accept_moderation_news_url news(:candidate)
      assert flash[:alert]
    end
    news(:candidate).unlock
    assert_redirected_to moderation_news_url news(:candidate)
  end

  test 'should accept news' do
    sign_in accounts 'admin_0'
    assert_difference 'News.candidate.count', -1 do
      post accept_moderation_news_url news(:candidate)
      assert flash[:alert]
    end
    assert_redirected_to news_url news(:candidate)
  end

  test 'should not refuse news' do
    sign_in accounts 'admin_0'

    assert_no_difference 'News.refused.count' do
      post refuse_moderation_news_url news(:candidate)
      assert_nil flash[:alert]
    end
    assert_response :success
  end

  test 'should not refuse locked news' do
    sign_in accounts 'admin_0'

    news(:candidate).lock_by users('visitor_0')
    assert_no_difference 'News.refused.count' do
      post refuse_moderation_news_url news(:candidate)
      assert flash[:alert]
    end
    news(:candidate).unlock
    assert_redirected_to moderation_news_url news(:candidate)
  end

  test 'should refuse news' do
    sign_in accounts 'admin_0'
    assert_difference 'News.refused.count' do
      post refuse_moderation_news_url news(:candidate), params: {
        message: 'so sorry'
      }
      assert_nil flash[:alert]
    end
    assert_redirected_to root_url
  end

  test 'should not rewrite locked news' do
    sign_in accounts 'admin_0'
    news(:candidate).lock_by users('visitor_0')
    assert_no_difference 'News.candidate.count' do
      post rewrite_moderation_news_url news(:candidate)
      assert flash[:alert]
    end
    news(:candidate).unlock
    assert_redirected_to moderation_news_url news(:candidate)
  end

  test 'should rewrite news' do
    sign_in accounts 'admin_0'
    assert_difference 'News.candidate.count', -1 do
      post rewrite_moderation_news_url news(:candidate)
      assert flash[:alert]
    end
    assert_redirected_to news_url news(:candidate)
  end

  test 'should reset news' do
    sign_in accounts 'admin_0'
    post reset_moderation_news_url news(:candidate)
    assert flash[:notice]
    assert_redirected_to moderation_news_url news(:candidate)
  end

  test 'should ppp news' do
    sign_in accounts 'admin_0'
    post ppp_moderation_news_url news(:news)
    assert flash[:notice]
    assert_redirected_to moderation_news_url news(:news)
  end

  test 'should get vote' do
    get vote_moderation_news_url news(:news)
    assert_response :success
  end
end
