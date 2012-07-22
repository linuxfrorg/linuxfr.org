# encoding: utf-8
require 'spec_helper'

describe "Vote" do
  let(:account) { FactoryGirl.create(:normal_account) }
  let(:node)    { FactoryGirl.create(:diary).node }

  it "creates a new instance when an account votes for a node" do
    node.vote_for(account)
    node.reload.score.should == 1
  end

  it "creates a new instance when an account votes against a node" do
    node.vote_against(account)
    node.reload.score.should == -1
  end

  it "can't be changed by an account if he changes his mind" do
    node.vote_against(account)
    node.vote_for(account)
    node.reload.score.should == 1
  end

  it "is idempotent" do
    3.times { node.vote_for(account) }
    node.reload.score.should == 1
  end

  it "decrements the number of votes for the account" do
    account.update_column(:nb_votes, 10)
    node.vote_for(account)
    account.reload.nb_votes.should == 9
  end
end
