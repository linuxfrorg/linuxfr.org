require "test_helper"

class Moderation::NewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "admin_0"
  end

  test "should list news" do
    get moderation_news_index_url

    assert_response :success
  end

  test "should show news" do
    get moderation_news_url news(:draft)

    assert_response :success
  end

  test "should get edit page" do
    get edit_moderation_news_url news(:draft)

    assert_response :success
  end

  test "should update news" do
    patch moderation_news_url news(:draft), params: { news: { wiki_body: "Hello world" } }

    assert flash[:notice]
    assert_redirected_to news_url news(:draft)
  end

  test "should update news as xhr" do
    patch moderation_news_url(news(:draft)), params: { news: { wiki_body: "Hello world" } }, xhr: true

    assert_response :success
  end

  test "should not accept locked news" do
    news(:candidate).lock_by users("visitor_0")
    post accept_moderation_news_url news(:candidate)

    assert flash[:alert]

    assert_redirected_to moderation_news_url news(:candidate)
    news(:candidate).unlock
  end

  test "should not accept empty news" do
    news(:first_part_only).paragraphs << Paragraph.new(wiki_body: News::DEFAULT_PARAGRAPH)
    post accept_moderation_news_url news(:first_part_only)

    assert flash[:alert]
    assert_redirected_to moderation_news_url news(:first_part_only)
  end

  test "should accept news" do
    assert_difference "News.candidate.count", -1 do
      post accept_moderation_news_url news(:candidate)

      assert flash[:alert]
    end
    assert_redirected_to news_url news(:candidate)
  end

  test "should not refuse news" do
    assert_no_difference "News.refused.count" do
      post refuse_moderation_news_url news(:candidate)
    end
    assert_response :success
  end

  test "should not refuse locked news" do
    news(:candidate).lock_by users("visitor_0")
    assert_no_difference "News.refused.count" do
      post refuse_moderation_news_url news(:candidate)

      assert flash[:alert]
    end

    assert_redirected_to moderation_news_url news(:candidate)
    news(:candidate).unlock
  end

  test "should refuse news" do
    assert_difference "News.refused.count" do
      post refuse_moderation_news_url news(:candidate), params: { message: "so sorry" }
    end
    assert_redirected_to root_url
  end

  test "should not rewrite locked news" do
    news(:candidate).lock_by users("visitor_0")
    assert_no_difference "News.candidate.count" do
      post rewrite_moderation_news_url news(:candidate)

      assert flash[:alert]
    end

    assert_redirected_to moderation_news_url news(:candidate)
    news(:candidate).unlock
  end

  test "should rewrite news" do
    assert_difference "News.candidate.count", -1 do
      post rewrite_moderation_news_url news(:candidate)

      assert flash[:alert]
    end
    assert_redirected_to news_url news(:candidate)
  end

  test "should reset news" do
    post reset_moderation_news_url news(:candidate)

    assert flash[:notice]
    assert_redirected_to moderation_news_url news(:candidate)
  end

  test "should ppp news" do
    post ppp_moderation_news_url news(:news)

    assert flash[:notice]
    assert_redirected_to moderation_news_url news(:news)

    # Reset
    Redis.new.del("nodes/ppp")
  end

  test "should get vote" do
    get vote_moderation_news_url news(:news)

    assert_response :success
  end
end
