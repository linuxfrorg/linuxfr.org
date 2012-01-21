# encoding: utf-8
require 'spec_helper'

describe "Accounts" do
  let!(:account) { FactoryGirl.create(:normal_account) }

  it "should authenticate use successfully" do
    get new_account_session_path
    fill_in 'account[login]', :with => account.login
    fill_in 'account[password]', :with => 'I<3J2EE'
    click_button "Se connecter"
    response.should_not contain("Identifiant ou mot de passe invalide.")
  end
end
