# encoding: utf-8
require 'spec_helper'

describe "Posts" do
  include Warden::Test::Helpers

  after(:each)  { Warden.test_reset! }

  let(:account) { FactoryGirl.create(:normal_account) }
  let(:modero)  { FactoryGirl.create(:moderator).account }
  let!(:post)   { FactoryGirl.create(:post) }
  let(:forum)   { post.forum }

  it "can be listed and showed" do
    visit forums_path
    status_code.should be(200)
    page.should have_content(post.title)
    click_link forum.title
    status_code.should be(200)
    page.should have_content(post.title)
    click_link "Lire la suite"
    status_code.should be(200)
    page.should have_content(post.title)
  end
end
