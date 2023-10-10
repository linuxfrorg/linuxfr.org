require "test_helper"

class Moderation::ParagraphsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "moderator_0"
  end

  test "should create paragraphs" do
    assert_difference "news(:news).paragraphs.in_second_part.count" do
      post redaction_news_paragraphs_url news(:news)
    end

    assert_response :created
  end

  test "should create in first part" do
    assert_difference "news(:first_part_only).paragraphs.in_first_part.count" do
      post redaction_news_paragraphs_url news(:first_part_only)
    end

    assert_response :created
  end

  test "should show paragraph" do
    get redaction_paragraph_url paragraphs(:one)

    assert_response :success
  end

  test "should edit paragraph" do
    get edit_redaction_paragraph_url paragraphs(:one)

    assert_response :success

    sign_in accounts "moderator_1"
    get edit_redaction_paragraph_url paragraphs(:one)

    assert_response :forbidden
  end

  test "should update paragraph" do
    patch redaction_paragraph_url paragraphs(:one), params: { paragraph: { wiki_body: "New body" } }

    assert_equal "New body", paragraphs(:one).reload.wiki_body
    assert_response :success
  end

  test "should unlock paragraph" do
    post unlock_redaction_paragraph_url paragraphs(:one)

    assert_response :no_content
  end
end
