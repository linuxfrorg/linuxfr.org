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

  validates_uniqueness_of :node_id, :scope => :user_id

  # TODO we should check if the user has already vote, and increment/decrement twice in that case

  def self.for(user, node)
    user.votes.create(:node_id => node.id, :vote => true)
    Node.increment_counter(:score, node.id)
  end

  def self.against(user, node)
    user.votes.create(:node_id => node.id, :vote => false)
    Node.decrement_counter(:score, node.id)
  end

end
