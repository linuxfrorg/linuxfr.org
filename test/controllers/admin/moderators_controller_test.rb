require "test_helper"

class Admin::ModeratorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "admin_0"
    @account = accounts "visitor_0"
  end

  test "should give moderator rights" do
    post admin_account_moderator_url @account

    assert_redirected_to @account.user
    assert_equal "Nouveau rôle : modérateur", flash[:notice]
    assert_predicate @account.reload, :moderator?
  end

  test "should remove moderator rights" do
    @account.give_moderator_rights!
    delete admin_account_moderator_url @account

    assert_redirected_to @account.user
    assert_equal "Rôle retiré : modérateur", flash[:notice]
    assert_not @account.reload.moderator?
  end
end
