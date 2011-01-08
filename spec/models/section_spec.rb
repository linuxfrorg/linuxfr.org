# == Schema Information
#
# Table name: sections
#
#  id                 :integer(4)      not null, primary key
#  state              :string(255)     default("published"), not null
#  title              :string(255)
#  cached_slug        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec_helper'

describe Section do
  subject { Factory.new(:section) }

  it { should be_valid }

  it "has an image method" do
    expect { subject.image }.to_not raise_error
  end

  it "has a published scope" do
    expect { Section.published.all }.to_not raise_error
  end
end
