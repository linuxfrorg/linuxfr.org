require 'spec_helper'

describe Vote do
  let(:user) { Factory(:user) }
  let(:node) { Factory(:diary).node }

  it "creates a new instance when an user votes for a node" do
    Vote.for(user, node)
    user.votes.count.should == 1
    node.reload.score.should == 1
  end

  it "creates a new instance when an user votes against a node" do
    Vote.against(user, node)
    user.votes.count.should == 1
    node.reload.score.should == -1
  end

  it "can't be changed by an user if he changes his mind" do
    Vote.against(user, node)
    Vote.for(user, node)
    user.votes.count.should == 1
    node.reload.score.should == 1
  end

  it "is idempotent" do
    3.times { Vote.for(user, node) }
    user.votes.count.should == 1
    node.reload.score.should == 1
  end

  it "decrements the number of votes for the user" do
    user.account.update_attribute(:nb_votes, 10)
    Vote.for(user, node)
    Account.where(:user_id => user.id).first.nb_votes.should == 9
  end
end
