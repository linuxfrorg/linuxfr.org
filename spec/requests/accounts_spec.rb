require 'spec_helper'

describe "Accounts" do
  before(:each) do
    User.delete_all
    Account.delete_all
  end

  let!(:account) { Factory.create(:moule_account) }

  it "should authenticate use successfully" do
    get new_account_session_path
    fill_in 'account[login]', :with => 'ptramo'
    fill_in 'account[password]', :with => 'I<3J2EE'
    click_button "Se connecter"
    response.should_not contain("Identifiant ou mot de passe invalide.")
  end

end
