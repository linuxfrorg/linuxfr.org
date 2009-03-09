# == Schema Information
# Schema version: 20090308232205
#
# Table name: poll_answers
#
#  id         :integer(4)      not null, primary key
#  poll_id    :integer(4)
#  answer     :string(255)
#  votes      :integer(4)      default(0), not null
#  position   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class PollAnswer < ActiveRecord::Base
  belongs_to :poll

  acts_as_list :scope => :poll

  named_scope :sorted, :order => "position ASC"

  validates_presence_of :answer, :message => "La description de la réponse ne peut pas être vide"

  def percent
    100.0 * votes / poll.total_votes
  end
end
