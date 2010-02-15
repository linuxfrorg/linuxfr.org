require 'spec_helper'

describe User do
  it "should be only reviewers, moderators and admins that are 'amr'" do
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

  it "should have an account" do
    user = Factory(:user)
    user.account.should_not be_nil
  end
end
