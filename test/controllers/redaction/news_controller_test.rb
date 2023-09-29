require 'test_helper'

class Redaction::NewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'visitor_0'
  end

  test 'should list news' do
    get redaction_news_index_url
    assert_response :success
  end

  test 'should get moderation' do
    get moderation_redaction_news_index_url format: :atom
    assert_response :success
  end

  test 'should show news' do
    get redaction_news_url news(:draft)
    assert_response :success
    assert_nil flash[:alert]
  end

  test 'should create news' do
    assert_difference('News.count') do
      post redaction_news_index_url,
           params: {
             news: {
               section: sections(:news),
               title: 'Hello world',
               cached_slug: 'hello-world',
               author_name: 'John Doe',
               author_email: 'test@example.com'
             }
           }
      assert_nil flash[:alert]
    end
    assert_redirected_to redaction_news_url News.last
  end

  test 'should get edit' do
    get edit_redaction_news_url news(:draft)
    assert_response :success
  end

  test 'should update news' do
    patch redaction_news_url(news(:draft)),
          params: {
            news: {
              title: 'Hello world',
              cached_slug: 'hello-world',
              author_name: 'John Doe',
              author_email: 'test@example.com'
            }
          }
    assert_nil flash[:alert]
    assert_response :success
  end

  test 'should reassign news' do
    sign_in accounts 'admin_0'
    post reassign_redaction_news_url news(:draft), params: {
      user_id: users(:visitor_1).id
    }
    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to redaction_news_url news(:draft)
  end

  test 'should get reorganize news page' do
    sign_in accounts 'admin_0'
    get reorganize_redaction_news_url news(:draft)
    assert_nil flash[:alert]
    assert_response :success
  end

  test 'should reorganize news' do
    put reorganized_redaction_news_url news(:draft), params: {
      news: {
        title: 'Hello world'
      }
    }
    assert_nil flash[:alert]
    assert_redirected_to redaction_news_url News.draft.last
  end

  test 'should get revision' do
    sign_in accounts 'admin_0'
    # This is required to generate a version numbered '1'
    put reorganized_redaction_news_url news(:draft), params: {
      news: {
        title: 'Hello world'
      }
    }
    get revision_redaction_news_url news(:draft).id, 1
    assert_nil flash[:alert]
    assert_response :success
  end

  test 'should followup news' do
    sign_in accounts 'admin_0'
    post followup_redaction_news_url news(:draft), params: {
      message: 'Hello world'
    }
    assert_nil flash[:alert]
    assert_redirected_to redaction_news_url News.draft.last
  end

  test 'should submit news' do
    sign_in accounts 'admin_0'

    # Required to unlock the draft
    put reorganized_redaction_news_url news(:draft), params: {
      news: {
        title: 'Hello world'
      }
    }

    post submit_redaction_news_url news(:draft).id
    assert_nil flash[:alert]
    assert_redirected_to redaction_url
  end

  test 'should erase news' do
    sign_in accounts 'admin_0'
    assert_difference('News.draft.count', -1) do
      post erase_redaction_news_url news(:draft)
    end
    assert_redirected_to redaction_url
  end

  test 'should mark news as urgent' do
    post urgent_redaction_news_url news(:draft)
    assert_redirected_to redaction_news_url news(:draft)
  end

  test 'should cancel news as urgent' do
    post cancel_urgent_redaction_news_url news(:draft)
    assert_redirected_to redaction_news_url news(:draft)
  end
end
