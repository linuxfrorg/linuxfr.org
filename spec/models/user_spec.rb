# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  name                :string(100)
#  homesite            :string(255)
#  jabber_id           :string(255)
#  role                :string(255)     default("moule"), not null
#  cached_slug         :string(255)
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer(4)
#  avatar_updated_at   :datetime
#  created_at          :datetime
#  updated_at          :datetime
#

require 'spec_helper'

describe User do
  before(:each) do
    User.delete_all
    Account.delete_all
  end

  it "is 'amr' only for reviewers, moderators and admins" do
    user = Factory(:user)
    user.should_not be_amr
    anon = Factory(:anonymous)
    anon.should_not be_amr
    writer = Factory(:writer)
    writer.should_not be_amr
    reviewer = Factory(:reviewer)
    reviewer.should be_amr
    moderator = Factory(:moderator)
    moderator.should be_amr
    admin = Factory(:admin)
    admin.should be_amr
    User.amr.all.should == [reviewer, moderator, admin]
  end

  it "has an account" do
    user = Factory(:user)
    user.account.should_not be_nil
  end
end
