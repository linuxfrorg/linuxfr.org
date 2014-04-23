# encoding: utf-8
require 'spec_helper'

describe "Wiki" do
  include Warden::Test::Helpers

  after(:each)  { Warden.test_reset! }

  let(:account) { FactoryGirl.create(:normal_account) }
  let!(:wiki)   { FactoryGirl.create(:wiki) }

  it "can be listed and showed" do
    visit "/wiki/pages"
    status_code.should be(200)
    page.should have_content(wiki.title)
    click_link wiki.title
    status_code.should be(200)
    page.should have_content(wiki.title)
  end
end

