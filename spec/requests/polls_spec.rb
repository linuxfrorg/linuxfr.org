require 'spec_helper'

describe "Polls" do
  before(:each) do
    User.delete_all
    Account.delete_all
    Node.delete_all
    Poll.delete_all
  end

  let(:account) { Factory.create(:account) }
  let!(:poll)   { Factory.create(:poll) }

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
