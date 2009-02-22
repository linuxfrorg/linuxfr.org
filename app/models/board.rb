# == Schema Information
# Schema version: 20090222161451
#
# Table name: boards
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  object_id   :integer(4)
#  object_type :string(255)
#  message     :text
#  created_at  :datetime
#

# It's the famous board, from DaCode (then templeet).
#
class Board < ActiveRecord::Base
  belongs_to :user
  belongs_to :object, :polymorphic => true

  default_scope :order => 'created_at DESC'
  named_scope :by_type, lambda { |type|
    { :conditions => { :object_type => type } }
  }

  # TODO mettre des messages en français
  validates_presence_of :object_type
  validates_presence_of :object_id
  validates_presence_of :user_id
  validates_presence_of :message

  # TODO transformer les liens en [url]

  # There are several boards:
  #  * the free one for testing
  #  * the writing board is used for collaborating the future news
  #  * the AMR board is used by the LinuxFR.org staff
  #  * and one board for each news in moderation.
  def self.free; 'Free' end
  def self.writing; 'Writing' end
  def self.amr; 'AMR' end
  def self.news; 'News' end

  # TODO check the type
  def self.[](type)
    board = Board.new
    board.object_type = type
    board
  end

### ACL ###

  # Can the given user see messages (and post) on this board?
  def accessible_by?(user)
    return false unless user
    case object_type
    when Board.news:    user.amr?
    when Board.amr:     user.amr?
    when Board.writing: user.can_post_on_board?
    when Board.free:    user.can_post_on_board?
    else                false
    end
  end

end
