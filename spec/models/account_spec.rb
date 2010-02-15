require 'spec_helper'

describe Account do
  it "should create a new instance given valid attributes" do
    Factory.create(:account)
  end
end
