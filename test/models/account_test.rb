require "test_helper"

class AccountTest < ActiveSupport::TestCase
  def test_should_create_account
    assert_difference "Account.count" do
      account = new_account

      assert account.save, account.errors.full_messages.to_sentence
    end
  end

  test "should get anonymous account" do
    assert Account.anonymous
    assert_equal "Anonyme", Account.anonymous.login
  end

  def test_should_require_login
    assert_no_difference "Account.count" do
      account = new_account(login: nil)

      assert_not account.save, account.errors.full_messages.to_sentence
    end
  end

  def test_should_require_email
    assert_no_difference "Account.count" do
      account = new_account(email: nil)

      assert_not account.save, account.errors.full_messages.to_sentence
    end
  end

  test "should display role" do
    assert_equal "visiteur", accounts("visitor_0").display_role(false)
    assert_equal "mainteneur", accounts("maintainer_0").display_role(false)
    assert_equal "animateur", accounts("editor_0").display_role(false)
    assert_equal "modérateur", accounts("moderator_0").display_role(false)
    assert_equal "admin", accounts("admin_0").display_role(false)
    assert_equal "compte fermé", accounts(:anonymous).display_role(false)
  end

  test "should display last seen on" do
    assert_equal "jamais", accounts(:anonymous).display_last_seen_on
    assert_equal "dans les 30 derniers jours", accounts("visitor_0").display_last_seen_on
    assert_equal "il y a moins d’un an", accounts("visitor_negative_karma").display_last_seen_on
  end

  test "should display inactive message" do
    assert_equal :closed, accounts(:anonymous).inactive_message
    assert_equal :inactive, accounts("visitor_0").inactive_message
  end

  test "should be able to block" do
    assert_not accounts("visitor_0").can_block?
    assert_not accounts("editor_0").can_block?
    assert_predicate accounts("moderator_0"), :can_block?
    assert_predicate accounts("admin_0"), :can_block?
  end

  test "should be able to plonk" do
    assert_not accounts("visitor_0").can_plonk?
    assert_not accounts("editor_0").can_plonk?
    assert_predicate accounts("moderator_0"), :can_plonk?
    assert_predicate accounts("admin_0"), :can_plonk?
  end

  def test_should_delete_account
    assert accounts(:joe).delete
  end

  protected

  def new_account(options = {})
    Account.new(
      { login: "quire",
        email: "quire@example.com",
        password: "quire69",
        password_confirmation: "quire69" }
      .merge(options)
    )
  end
end
