require 'test_helper'

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    admin = accounts('admin_0')
    admin.confirm
    sign_in admin
  end

  test 'list accounts' do
    get admin_accounts_url
    assert_response :success
  end

  test 'send password reset' do
    post password_admin_account_url(accounts(:anonymous))
    assert_redirected_to admin_accounts_url
  end

  test 'give karma' do
    post karma_admin_account_url(accounts(:anonymous))
    assert_redirected_to accounts(:anonymous).user
  end

  test 'update account' do
    patch admin_account_url(accounts(:anonymous))
    assert_redirected_to admin_accounts_url
  end

  test 'destroy account' do
    delete admin_account_url(accounts(:anonymous))
    assert_redirected_to admin_accounts_url
  end
end
