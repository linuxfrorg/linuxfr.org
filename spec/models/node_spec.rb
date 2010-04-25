require 'spec_helper'

describe Node do
  subject { Factory.build(:node) }
  it { should be_valid }
end
