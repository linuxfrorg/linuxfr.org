require 'test_helper'

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'admin_0'
  end

  test 'should list accounts' do
    get admin_accounts_url
    assert_response :success
  end

  test 'should find accounts' do
    get admin_accounts_url, params: {
      login: 'test',
      date: '2016-01-01',
      ip: '127.0.0.1',
      email: 'test@example.com',
      inactive: '1'
    }
    assert_response :success
  end

  test 'should send password reset' do
    post password_admin_account_url(accounts(:anonymous))
    assert_redirected_to admin_accounts_url
  end

  test 'should give karma' do
    post karma_admin_account_url(accounts(:anonymous))
    assert_redirected_to accounts(:anonymous).user
  end

  test 'should activate/inactivate account' do
    patch admin_account_url accounts(:anonymous)
    assert_nil flash[:alert]
    assert_equal 'Compte réactivé', flash[:notice]
    assert_redirected_to admin_accounts_url

    patch admin_account_url accounts(:anonymous)
    assert_nil flash[:alert]
    assert_equal 'Compte désactivé', flash[:notice]
    assert_redirected_to admin_accounts_url
  end

  test 'should destroy account' do
    delete admin_account_url(accounts(:anonymous))
    assert_redirected_to admin_accounts_url
  end
end
