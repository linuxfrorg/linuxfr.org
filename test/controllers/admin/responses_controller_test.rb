require 'test_helper'

class Admin::ResponsesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'admin_0'
  end

  test 'should list responses' do
    get admin_responses_url
    assert_response :success
  end

  test 'should get new' do
    get new_admin_response_url
    assert_response :success
  end

  test 'should create response' do
    assert_difference('Response.count') do
      post admin_responses_url, params: {
        response: {
          title: 'hello world my response'
        }
      }
      assert_nil flash[:alert]
      assert flash[:notice]
    end
    assert_redirected_to admin_responses_url
  end

  test 'should not create response' do
    assert_no_difference('Response.count') do
      post admin_responses_url, params: {
        response: {
          title: ''
        }
      }
      assert flash[:alert]
      assert_nil flash[:notice]
    end
    assert_response :success
  end

  test 'should get edit' do
    get edit_admin_response_url(responses(:one))
    assert_response :success
  end

  test 'should update response' do
    patch admin_response_url(responses(:one)), params: {
      response: {
        title: 'hello world my response'
      }
    }
    assert_nil flash[:alert]
    assert flash[:notice]
    assert_redirected_to admin_responses_url
  end

  test 'should not update response' do
    patch admin_response_url(responses(:one)), params: {
      response: {
        title: ''
      }
    }
    assert flash[:alert]
    assert_nil flash[:notice]
    assert_response :success
  end

  test 'should destroy response' do
    assert_difference('Response.count', -1) do
      delete admin_response_url(responses(:one))
      assert_nil flash[:alert]
      assert flash[:notice]
    end
    assert_redirected_to admin_responses_url
  end
end
