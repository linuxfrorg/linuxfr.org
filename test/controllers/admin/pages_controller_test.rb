require "test_helper"

class Admin::ModeratorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "admin_0"
  end

  test "should list pages" do
    get admin_pages_url

    assert_response :success
  end

  test "should get new" do
    get new_admin_page_url

    assert_response :success
  end

  test "should create page" do
    assert_difference("Page.count") do
      post admin_pages_url, params: {
        page: {
          title: "hello world my page",
          slug: "hello-world-my-page",
          body: "hello world"
        }
      }

      assert flash[:notice]
    end
    assert_redirected_to admin_pages_url
  end

  test "should not create page" do
    assert_no_difference("Page.count") do
      post admin_pages_url, params: {
        page: {
          slug: "hello-world-my-page",
          body: "hello world"
        }
      }

      assert flash[:alert]
    end
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_page_url(pages(:one))

    assert_response :success
  end

  test "should update page" do
    patch admin_page_url(pages(:one)), params: {
      page: {
        title: "hello world my page",
        slug: "hello-world-my-page",
        body: "hello world"
      }
    }

    assert flash[:notice]
    assert_redirected_to admin_pages_url
  end

  test "should not update page" do
    patch admin_page_url(pages(:one)), params: {
      page: {
        title: "",
        slug: "hello-world-my-page",
        body: "hello world"
      }
    }

    assert flash[:alert]
    assert_response :success
  end

  test "should destroy page" do
    assert_difference("Page.count", -1) do
      delete admin_page_url(pages(:one))

      assert flash[:notice]
    end
    assert_redirected_to admin_pages_url
  end
end
