require 'spec_helper'

describe "Homepage" do
  before :each do
    Factory(:user)
  end

  it "works for anonymous" do
    get '/'
  end

  it "works for authenticated user" do
    get '/'
    fill_in :account_login, :with => "ptramo"
    fill_in :account_password, :with => "I<3J2EE"
    click_button "Se connecter"
    response.should_not contain("Identifiant ou mot de passe invalide.")
    get '/'
    response.should have_selector(".login") do |box|
      box.should contain("ptramo")
    end
  end
end
