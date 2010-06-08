# == Schema Information
#
# Table name: relevances
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  comment_id :integer(4)
#  vote       :boolean(1)
#  created_at :datetime
#

require 'spec_helper'

describe Relevance do
  before(:each) do
    User.delete_all
    Account.delete_all
  end

  let(:user)    { Factory(:user) }
  let(:writer)  { Factory(:writer) }
  let(:comment) { Factory(:comment, :user_id => writer.id) }

  it "creates an instance when an user votes for a comment" do
    Relevance.for(user, comment)
    user.relevances.count.should == 1
    comment.reload.score.should == 1
  end

  it "creates an instance when an user votes against" do
    Relevance.against(user, comment)
    user.relevances.count.should == 1
    comment.reload.score.should == -1
  end

  it "can't be changed by an user if he changes his mind" do
    Relevance.for(user, comment)
    Relevance.against(user, comment)
    user.relevances.count.should == 1
    comment.reload.score.should == 1
  end

  it "is idempotent" do
    3.times { Relevance.for(user, comment) }
    user.relevances.count.should == 1
    comment.reload.score.should == 1
  end

  it "decrements the number of votes for the user" do
    user.account.update_attribute(:nb_votes, 10)
    Relevance.for(user, comment)
    Account.where(:user_id => user.id).first.nb_votes.should == 9
  end
end
