require 'spec_helper'

describe "Wiki" do
  include Warden::Test::Helpers

  before(:each) do
    User.delete_all
    Account.delete_all
    Node.delete_all
  end

  after(:each)  { Warden.test_reset! }

  let(:account) { Factory.create(:account) }
  let!(:wiki)   { Factory.create(:wiki) }

  it "can be listed and showed" do
    get "/"
    assert_response :success
    response.should contain(wiki.title)
    click_link wiki.title
    assert_response :success
    response.should contain(wiki.title)
  end
end

