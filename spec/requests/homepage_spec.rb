# encoding: utf-8
require 'spec_helper'

describe "Homepage" do
  let!(:account) { FactoryGirl.create(:normal_account) }

  it "works for anonymous" do
    get '/'
    assert_response :success
  end

  it "works for authenticated user" do
    get '/news'
    fill_in :account_login_sidebar, :with => account.login
    fill_in :account_password_sidebar, :with => "I<3J2EE"
    click_button "Se connecter"
    response.should_not contain("Identifiant ou mot de passe invalide.")
    get '/'
    assert_response :success
    response.should have_selector(".login") do |box|
      box.should contain(account.login)
    end
  end
end
