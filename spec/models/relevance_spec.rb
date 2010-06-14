require 'spec_helper'

describe "Relevance" do
  before(:each) do
    User.delete_all
    Account.delete_all
    $redis.flushdb
  end

  let(:user)    { Factory(:user) }
  let(:writer)  { Factory(:writer) }
  let(:comment) { Factory(:comment, :user_id => writer.id) }

  it "creates an instance when an user votes for a comment" do
    comment.vote_for(user)
    comment.reload.score.should == 1
  end

  it "creates an instance when an user votes against" do
    comment.vote_against(user)
    comment.reload.score.should == -1
  end

  it "can't be changed by an user if he changes his mind" do
    comment.vote_for(user)
    comment.vote_against(user)
    comment.reload.score.should == 1
  end

  it "is idempotent" do
    3.times { comment.vote_for(user) }
    comment.reload.score.should == 1
  end

  it "decrements the number of votes for the user" do
    user.account.update_attribute(:nb_votes, 10)
    comment.vote_for(user)
    Account.where(:user_id => user.id).first.nb_votes.should == 9
  end
end
