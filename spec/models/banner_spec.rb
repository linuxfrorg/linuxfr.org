# == Schema Information
#
# Table name: banners
#
#  id      :integer(4)      not null, primary key
#  title   :string(255)
#  content :text
#

require 'spec_helper'

describe Banner do
  subject { Factory.new(:banner) }

  it { should be_valid }

  it "returns the text of a banner on random" do
    Factory(:banner)
    Banner.random.should be_present
  end
end
