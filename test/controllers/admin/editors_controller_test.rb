require 'test_helper'

class Admin::EditorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'admin_0'
  end

  test 'should authorize editor' do
    assert_difference 'Account.editor.count' do
      post admin_account_editor_url accounts('visitor_0')

      assert flash[:notice]
    end
    assert_redirected_to accounts('visitor_0').user
  end

  test 'should destroy editor' do
    assert_difference 'Account.editor.count', -1 do
      delete admin_account_editor_url accounts('editor_0')

      assert flash[:notice]
    end
    assert_redirected_to accounts('editor_0').user
  end
end
