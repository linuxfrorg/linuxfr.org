# == Schema Information
#
# Table name: sections
#
#  id                 :integer(4)      not null, primary key
#  state              :string(255)     default("published"), not null
#  title              :string(255)
#  cached_slug        :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer(4)
#  image_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec_helper'

describe Section do
  subject { Factory.new(:section) }

  it { should be_valid }

  it "has an image method" do
    lambda { subject.image }.should_not raise_error
  end

  it "has a published scope" do
    lambda { Section.published.all }.should_not raise_error
  end
end
