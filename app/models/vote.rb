# == Schema Information
# Schema version: 20090130001540
#
# Table name: votes
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  node_id    :integer(4)
#  vote       :boolean(1)
#  created_at :datetime
#

class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :node

  # An user can vote for a node...
  def self.for(user, node)
    cancel(user, node)
    user.votes.create(:node_id => node.id, :vote => true)
    Node.increment_counter(:score, node.id)
  end

  # ...or he can vote against it
  def self.against(user, node)
    cancel(user, node)
    user.votes.create(:node_id => node.id, :vote => false)
    Node.decrement_counter(:score, node.id)
  end

protected

  # Cancel a previous vote
  def self.cancel(user, node)
    vote = user.votes.first(:conditions => {:node_id => node.id})
    return if vote.nil?
    if vote.vote
      Node.decrement_counter(:score, node.id)
    else
      Node.increment_counter(:score, node.id)
    end
    vote.destroy
  end

end
