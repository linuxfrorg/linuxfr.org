require 'spec_helper'

describe Account do
  it "is valid" do
    Factory.build(:account).should be_valid
  end
end
