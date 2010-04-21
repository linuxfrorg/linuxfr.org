require 'spec_helper'

describe Banner do
  subject { Factory.new(:banner) }

  it { should be_valid }

  it "should return the text of a banner on random" do
    Factory(:banner)
    Banner.random.should be_present
  end
end
