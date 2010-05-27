require 'spec_helper'

describe "Homepage" do
  before(:each) do
    News.delete_all
    Section.delete_all
    Node.delete_all
    User.delete_all
    Account.delete_all
  end

  let!(:account) { Factory.create(:account) }

  it "works for anonymous" do
    get '/'
    assert_response :success
  end
end
