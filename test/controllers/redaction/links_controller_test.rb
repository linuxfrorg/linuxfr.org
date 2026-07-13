require "test_helper"

class Admin::LinksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in accounts "moderator_1"
  end

  test "should not get new" do
    sign_in accounts "visitor_0"
    get new_redaction_news_link_url news(:news)

    assert_response :forbidden
  end

  test "should get new" do
    get new_redaction_news_link_url news(:news)

    assert_response :success
  end

  test "should create link" do
    assert_difference "Link.count" do
      post redaction_links_url params: {
        link: {
          lang: "fr",
          title: "LinuxFR",
          url: "https://linuxfr.org"
        },
        news_id: news(:news).id
      }
    end
    assert_response :success
  end

  test "should not create link" do
    assert_no_difference "Link.count" do
      post redaction_links_url params: {
        link: {
          lang: "fr",
          url: "https://linuxfr.org"
        },
        news_id: news(:news).id
      }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_redaction_link_url links(:one)

    assert_response :success
  end

  test "should not get edit" do
    get edit_redaction_link_url links(:one)

    sign_in accounts "moderator_0"
    get edit_redaction_link_url links(:one)

    assert_response :forbidden

    post unlock_redaction_link_url links(:one)
  end

  test "should update link" do
    patch redaction_link_url links(:one), params: {
      link: {
        lang: "fr",
        title: "LinuxFR",
        url: "https://linuxfr.org"
      }
    }

    assert_response :success
  end

  test "should not update link" do
    patch redaction_link_url links(:one), params: {
      link: {
        lang: "fr",
        title: "",
        url: "https://linuxfr.org"
      }
    }

    assert_response :unprocessable_entity
  end

  test "should unlock link" do
    post unlock_redaction_link_url links(:one)

    assert_response :no_content
  end
end
