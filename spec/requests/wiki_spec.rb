# encoding: utf-8
require 'spec_helper'

describe "Wiki" do
  include Warden::Test::Helpers

  after(:each)  { Warden.test_reset! }

  let(:account) { FactoryGirl.create(:normal_account) }
  let!(:wiki)   { FactoryGirl.create(:wiki) }

  it "can be listed and showed" do
    get "/wiki/pages"
    assert_response :success
    response.should contain(wiki.title)
    click_link wiki.title
    assert_response :success
    response.should contain(wiki.title)
  end
end

