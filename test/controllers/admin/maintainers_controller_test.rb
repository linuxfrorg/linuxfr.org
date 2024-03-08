require "test_helper"

class Admin::MaintainersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts "admin_0"
    @account = accounts "visitor_0"
  end

  test "should give maintainer rights" do
    post admin_account_maintainer_url @account

    assert_redirected_to @account.user
    assert_equal "Nouveau rôle : mainteneur", flash[:notice]
    assert_predicate @account.reload, :maintainer?
  end

  test "should remove maintainer rights" do
    @account.give_maintainer_rights!
    delete admin_account_maintainer_url @account

    assert_redirected_to @account.user
    assert_equal "Rôle retiré : mainteneur", flash[:notice]
    assert_not @account.reload.maintainer?
  end
end
