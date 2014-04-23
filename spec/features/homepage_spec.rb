# encoding: utf-8
require 'spec_helper'

describe "Homepage" do
  let!(:account) { FactoryGirl.create(:normal_account) }

  it "works for anonymous" do
    visit '/'
    status_code.should be(200)
  end

  it "works for authenticated user" do
    visit '/news'
    fill_in :account_login_sidebar, with: account.login
    fill_in :account_password_sidebar, with: "I<3J2EE"
    click_button "Se connecter"
    page.should_not have_content("Identifiant ou mot de passe invalide.")
    visit '/'
    status_code.should be(200)
    page.should have_selector(".login") do |box|
      box.should have_content(account.login)
    end
  end
end
