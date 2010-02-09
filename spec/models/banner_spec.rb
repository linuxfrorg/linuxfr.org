require 'spec_helper'

describe Banner do
  it "should create a new instance given valid attributes" do
    Factory.build(:banner).save!
  end

  it "should return the text of a banner on random" do
    Factory.create(:banner)
    Banner.random.should_not be_nil
  end
end
