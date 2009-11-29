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

# The users can vote on content.
# Technically, they vote on the node associated to this content, but who cares?
#
# Note: these votes are also used the AMR team for news in moderation.
#
class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :node

  named_scope :old, lambda {
    { :conditions => ["created_at < ?", DateTime.now - 3.months] }
  }

  validates_uniqueness_of :node_id, :scope => :user_id

  # An user can vote for a node...
  def self.for(user, node)
    Account.decrement_counter(:nb_votes, user.account.id)
    cancel(user, node)
    user.votes.create(:node_id => node.id, :vote => true)
    Node.increment_counter(:score, node.id)
    node.compute_interest
  end

  # ...or he can vote against it
  def self.against(user, node)
    Account.decrement_counter(:nb_votes, user.account.id)
    cancel(user, node)
    user.votes.create(:node_id => node.id, :vote => false)
    Node.decrement_counter(:score, node.id)
    node.compute_interest
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

### Announce the vote in a board ###

  after_create :announce
  def announce
    c = node.content
    return unless c.announce_vote?
    c.boards.vote.create(:message => "#{current_user.name} a voté #{word}", :user_id => user_id)
  end

  def word
    vote? ? 'Pour' : 'Contre'
  end

end
