# encoding: utf-8
require 'spec_helper'

describe "Accounts" do
  let!(:account) { FactoryGirl.create(:normal_account) }

  it "should authenticate use successfully" do
    visit new_account_session_path
    within '#contents' do
      fill_in 'account[login]', with: account.login
      fill_in 'account[password]', with: 'I<3J2EE'
      click_button "Se connecter"
    end
    page.should_not have_content("Identifiant ou mot de passe invalide.")
  end
end
