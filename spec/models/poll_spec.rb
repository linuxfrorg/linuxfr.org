# == Schema Information
#
# Table name: polls
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("draft"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Poll do
  let(:poll) { Factory.create(:poll) }

  it "can be archived" do
    poll.state_name.should == :published
    poll.archive!
    poll.state_name.should == :archived
  end
end
