require 'spec_helper'

describe Account do
  it "should be valid" do
    Factory.build(:account).should be_valid
  end
end
