require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  def test_should_create_account
    assert_difference 'Account.count' do
      account = new_account
      assert account.save, account.errors.full_messages.to_sentence
    end
  end

  def test_should_require_login
    assert_no_difference 'Account.count' do
      account = new_account(login: nil)
      assert_not account.save, account.errors.full_messages.to_sentence
    end
  end

  def test_should_require_email
    assert_no_difference 'Account.count' do
      account = new_account(email: nil)
      assert_not account.save, account.errors.full_messages.to_sentence
    end
  end

  def test_should_delete_account
    assert accounts(:joe).delete
  end

  protected

  def new_account(options = {})
    Account.new(
      { login: 'quire',
        email: 'quire@example.com',
        password: 'quire69',
        password_confirmation: 'quire69' }
      .merge(options)
    )
  end
end
