require 'spec_helper'

describe "Homepage" do
  before(:each) do
    News.delete_all
    Section.delete_all
    Node.delete_all
    User.delete_all
    Account.delete_all
    Rails.cache.clear
  end

  let!(:account) { Factory.create(:account) }

  it "works for anonymous" do
    get '/'
    assert_response :success
  end

  it "works for authenticated user" do
    get '/news'
    fill_in :account_login, :with => account.login
    fill_in :account_password, :with => "I<3J2EE"
    click_button "Se connecter"
    response.should_not contain("Identifiant ou mot de passe invalide.")
    get '/'
    assert_response :success
    response.should have_selector(".login") do |box|
      box.should contain(account.login)
    end
  end
end
