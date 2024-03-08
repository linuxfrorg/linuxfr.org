require "test_helper"

class Admin::SectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in accounts "admin_0"
  end

  test "should get new" do
    get new_admin_section_url

    assert_response :success
  end

  test "should create section" do
    assert_difference("Section.count") do
      post admin_sections_url, params: {
        section: { title: "title" }
      }
    end

    follow_redirect!

    assert_response :success
    assert_select "p", "Il vous reste\n0\navis"
  end

  test "should not create section" do
    assert_no_difference("Section.count") do
      post admin_sections_url, params: {
        section: { title: "" }
      }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_section_url(sections(:default))

    assert_response :success
  end

  test "should update section" do
    patch admin_section_url(sections(:default)), params: {
      section: {
        title: "hello world"
      }
    }

    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_select "a", "hello world"
  end

  test "should not update section" do
    patch admin_section_url(sections(:default)), params: {
      section: {
        title: ""
      }
    }

    assert flash[:alert]
    assert_response :success
  end

  test "should destroy section" do
    assert_difference("Section.published.count", -1) do
      delete admin_section_url(sections(:default))
    end

    assert_redirected_to admin_sections_path
  end
end
