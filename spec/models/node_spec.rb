require 'spec_helper'

describe Node do
  subject { Factory.new(:node) }
  it { should be_valid }
end
