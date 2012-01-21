# encoding: utf-8
require 'spec_helper'

describe "Polls" do
  let(:account) { FactoryGirl.create(:normal_account) }
  let!(:poll)   { FactoryGirl.create(:poll) }

  it "can be listed and showed" do
    get polls_path
    assert_response :success
    response.should contain(poll.title)
    response.should contain("Debian")
    click_link "Lire la suite"
    assert_response :success
    response.should contain(poll.title)
  end
end
