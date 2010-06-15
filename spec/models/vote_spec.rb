require 'spec_helper'

describe "Vote" do
  before(:each) do
    User.delete_all
    Account.delete_all
    $redis.flushdb
  end

  let(:user) { Factory(:user) }
  let(:node) { Factory(:diary).node }

  it "creates a new instance when an user votes for a node" do
    node.vote_for(user)
    node.reload.score.should == 1
  end

  it "creates a new instance when an user votes against a node" do
    node.vote_against(user)
    node.reload.score.should == -1
  end

  it "can't be changed by an user if he changes his mind" do
    node.vote_against(user)
    node.vote_for(user)
    node.reload.score.should == 1
  end

  it "is idempotent" do
    3.times { node.vote_for(user) }
    node.reload.score.should == 1
  end

  it "decrements the number of votes for the user" do
    user.account.update_attribute(:nb_votes, 10)
    node.vote_for(user)
    Account.where(:user_id => user.id).first.nb_votes.should == 9
  end
end
