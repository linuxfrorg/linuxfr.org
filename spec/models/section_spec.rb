require 'spec_helper'

describe Section do
  subject { Factory.new(:section) }

  it { should be_valid }

  it "has an image method" do
    lambda { subject.image }.should_not raise_error
  end
end

