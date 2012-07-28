# encoding: UTF-8
# == Schema Information
#
# Table name: poll_answers
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  answer     :string(128)      not null
#  votes      :integer          default(0), not null
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

#
class PollAnswer < ActiveRecord::Base
  belongs_to :poll

  acts_as_list :scope => :poll

  attr_accessible :answer

  validates :answer, :presence => { :message => "La description de la réponse ne peut pas être vide" }

  def percent
    return 0.0 if poll.total_votes == 0
    "%.1f" % (100.0 * votes / poll.total_votes)
  end

  def vote(ip)
    self.class.increment_counter(:votes, self.id)
    poll.vote(ip)
  end

  def formatted
    linkify answer
  end
end
