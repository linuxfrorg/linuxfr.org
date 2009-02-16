# == Schema Information
# Schema version: 20090205000452
#
# Table name: relevances
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  comment_id :integer(4)
#  vote       :boolean(1)
#  created_at :datetime
#

# The users can indicates if a comment is relevant... or not.
#
class Relevance < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  validates_uniqueness_of :comment_id, :scope => :user_id

  # An user can vote for a comment...
  def self.for(user, comment)
    user.relevances.create(:comment_id => comment.id, :vote => true)
    Comment.increment_counter(:score, comment.id)
  end

  # ...or he can vote against it
  def self.against(user, comment)
    user.relevances.create(:comment_id => comment.id, :vote => false)
    Comment.decrement_counter(:score, comment.id)
  end

end
