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

  scope :old, lambda { where("created_at < ?", DateTime.now - 3.months) }

  validates :comment_id, :uniqueness => { :scope => :user_id, :message => "Vous avez déjà voté sur ce commentaire" }

  # An user can vote for a comment...
  def self.for(user, comment)
    relevance = user.relevances.create(:comment_id => comment.id, :vote => true)
    return if relevance.invalid?
    Account.decrement_counter(:nb_votes, user.account.id)
    Comment.increment_counter(:score, comment.id)
  end

  # ...or he can vote against it
  def self.against(user, comment)
    relevance = user.relevances.create(:comment_id => comment.id, :vote => false)
    return if relevance.invalid?
    Account.decrement_counter(:nb_votes, user.account.id)
    Comment.decrement_counter(:score, comment.id)
  end

end
