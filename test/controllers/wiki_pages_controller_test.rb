require "test_helper"

class WikiPagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should list wiki pages" do
    get wiki_pages_url format: :atom

    assert_response :success
  end

  test "should show wiki page" do
    get wiki_page_url wiki_pages(:one)

    assert_response :success
  end

  test "should not show wiki page" do
    get wiki_page_url "none"

    assert_response :success
  end

  test "should not show wiki page for signed in user" do
    sign_in accounts "editor_0"

    get wiki_page_url "none"

    assert_redirected_to new_wiki_page_url title: "none"
  end

  test "should get new" do
    sign_in accounts "editor_0"

    get new_wiki_page_url

    assert_response :success
  end

  test "should preview wiki page" do
    sign_in accounts "editor_0"

    assert_no_difference("WikiPage.count") do
      post wiki_pages_url, params: {
        wiki_page: { title: "Test" },
        commit: "Prévisualiser"
      }
    end
    assert_response :success
  end

  test "should create wiki page" do
    sign_in accounts "editor_0"

    assert_difference("WikiPage.count") do
      post wiki_pages_url, params: {
        wiki_page: {
          title: "Test",
          wiki_body: "Test"
        }
      }

      assert flash[:notice]
    end
    assert_redirected_to wiki_page_url(WikiPage.last)
  end

  test "should get edit" do
    sign_in accounts "editor_0"

    get edit_wiki_page_url wiki_pages(:one)

    assert_response :success
  end

  test "should preview update" do
    sign_in accounts "editor_0"

    patch wiki_page_url(wiki_pages(:one)), params: {
      wiki_page: {
        title: "Test",
        wiki_body: "Test"
      },
      commit: "Prévisualiser"
    }

    assert_nil flash[:alert]
    assert_nil flash[:notice]
    assert_response :success
  end

  test "should update wiki page" do
    sign_in accounts "editor_0"

    patch wiki_page_url(wiki_pages(:one)), params: {
      wiki_page: {
        title: "Test",
        wiki_body: "Test"
      }
    }

    assert flash[:notice]
    assert_redirected_to wiki_page_url(wiki_pages(:one))
  end

  test "should get revision" do
    get revision_wiki_page_url wiki_pages(:one), "1"

    assert_nil flash[:alert]
    assert_response :success
  end

  test "should get changes" do
    sign_in accounts "admin_0"
    get modifications_wiki_pages_url

    assert_nil flash[:alert]
    assert_response :success
  end

  test "should get pages" do
    sign_in accounts "admin_0"
    get pages_wiki_pages_url

    assert_nil flash[:alert]
    assert_response :success
  end

  test "should destroy wiki page" do
    sign_in accounts "admin_0"
    assert_difference("Node.visible.count", -1) do
      delete wiki_page_url(wiki_pages(:one))

      assert flash[:notice]
    end
    assert_redirected_to wiki_page_url wiki_pages(:homePage)
  end
end
