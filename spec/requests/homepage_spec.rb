require 'spec_helper'

describe "Homepage" do
  before(:each) do
    User.delete_all
    Account.delete_all
    Section.delete_all
    News.delete_all
    Node.delete_all
  end

  let(:user) { Factory(:user) }

  it "works for anonymous" do
    get '/'
    assert_response :success
  end

  it "works for authenticated user" do
    get '/'
    fill_in :account_login, :with => user.account.login
    fill_in :account_password, :with => "I<3J2EE"
    click_button "Se connecter"
    response.should_not contain("Identifiant ou mot de passe invalide.")
    get '/'
    assert_response :success
    response.should have_selector(".login") do |box|
      box.should contain(user.name)
    end
  end
end
