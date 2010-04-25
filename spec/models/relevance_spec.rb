require 'spec_helper'

describe Relevance do
  let(:user)    { Factory(:user) }
  let(:writer)  { Factory(:writer) }
  let(:comment) { Factory(:comment, :user_id => writer.id) }

  it "should create an instance when an user votes for a comment" do
    Relevance.for(user, comment)
    user.relevances.count.should == 1
    comment.reload.score.should == 1
  end

  it "should create an instance when an user votes against" do
    Relevance.against(user, comment)
    user.relevances.count.should == 1
    comment.reload.score.should == -1
  end

  it "should not be possible for an user to change his mind" do
    Relevance.for(user, comment)
    Relevance.against(user, comment)
    user.relevances.count.should == 1
    comment.reload.score.should == 1
  end

  it "should be idempotent" do
    3.times { Relevance.for(user, comment) }
    user.relevances.count.should == 1
    comment.reload.score.should == 1
  end

  it "should decrement the number of votes for the user" do
    user.account.update_attribute(:nb_votes, 10)
    Relevance.for(user, comment)
    Account.where(:user_id => user.id).first.nb_votes.should == 9
  end
end
