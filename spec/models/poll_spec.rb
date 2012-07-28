# encoding: utf-8
# == Schema Information
#
# Table name: polls
#
#  id                :integer          not null, primary key
#  state             :string(10)       default("draft"), not null
#  title             :string(128)      not null
#  cached_slug       :string(128)
#  created_at        :datetime
#  updated_at        :datetime
#  wiki_explanations :text
#  explanations      :text
#

require 'spec_helper'

describe Poll do
  let(:poll) { FactoryGirl.create(:poll) }

  it "can be archived" do
    poll.state_name.should == :published
    poll.archive!
    poll.state_name.should == :archived
  end
end
