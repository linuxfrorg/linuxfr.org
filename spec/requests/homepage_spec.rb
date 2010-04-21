require 'spec_helper'

describe "Homepage" do
  before :each do
    @user = Factory(:user)
  end

  it "works for anonymous" do
    get '/'
  end

  it "works for authenticated user" do
    get '/'
    fill_in :account_login, :with => @user.account.login
    fill_in :account_password, :with => "I<3J2EE"
    click_button "Se connecter"
    response.should_not contain("Identifiant ou mot de passe invalide.")
    get '/'
    response.should have_selector(".login") do |box|
      box.should contain(@user.name)
    end
  end
end
