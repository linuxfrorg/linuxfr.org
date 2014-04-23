# encoding: utf-8
require 'spec_helper'

describe "Polls" do
  let(:account) { FactoryGirl.create(:normal_account) }
  let!(:poll)   { FactoryGirl.create(:poll) }

  it "can be listed and showed" do
    visit polls_path
    status_code.should be(200)
    page.should have_content(poll.title)
    page.should have_content("Debian")
    click_link "Lire la suite"
    status_code.should be(200)
    page.should have_content(poll.title)
  end
end
