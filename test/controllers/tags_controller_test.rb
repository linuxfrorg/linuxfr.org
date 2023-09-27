require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'visitor_0'
  end

  test 'should list tags' do
    get tags_url
    assert_response :success
  end

  test 'should show tag' do
    get tag_url tags(:one)
    assert_response :success
  end

  test 'should get edit page' do
    get new_node_tag_url nodes(:one), tags(:one)
    assert_response :success
  end

  test 'should create tag' do
    assert_difference 'Tag.visible.count' do
      post node_tags_url(nodes(:one)), params: {
        tags: 'Hello'
      }
      assert_nil flash[:alert]
    end

    assert_redirected_to user_diary_url(users('visitor_1'), diaries(:one))
  end

  test 'should autocomplete tag' do
    get autocomplete_tags_url, params: {
      q: 'Hello'
    }
    assert_response :success
  end

  test 'should destroy tag' do
    assert_difference 'Tagging.count', -1 do
      delete node_tag_url(nodes(:one), tags(:one).name)
      assert_nil flash[:alert]
    end
    assert_redirected_to user_diary_url(users('visitor_1'), diaries(:one))
  end
end
