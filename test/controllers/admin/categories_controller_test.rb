require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "admin_0"
  end

  test "should list categories" do
    get admin_categories_url

    assert_response :success
  end

  test "should get new" do
    get new_admin_category_url

    assert_response :success
  end

  test "should not create category" do
    assert_no_difference("Category.count") do
      post admin_categories_url, params: {
        category: { title: "" }
      }

      assert flash[:alert]
    end
    assert_response :success
  end

  test "should create category" do
    assert_difference("Category.count") do
      post admin_categories_url, params: {
        category: { title: "Hello world" }
      }

      assert_nil flash[:alert]
    end
    assert_redirected_to admin_categories_url
  end

  test "should get edit" do
    get edit_admin_category_url(categories(:one))

    assert_response :success
  end

  test "should not update category" do
    patch admin_category_url(categories(:one)), params: {
      category: { title: "" }
    }

    assert flash[:alert]
    assert_response :success
  end

  test "should update category" do
    patch admin_category_url(categories(:one)), params: {
      category: { title: "Hello world" }
    }

    assert_nil flash[:alert]
    assert_redirected_to admin_categories_url
  end

  test "should destroy category" do
    assert_difference("Category.count", -1) do
      delete admin_category_url(categories(:two))

      assert_nil flash[:alert]
    end
    assert_redirected_to admin_categories_url
  end
end
