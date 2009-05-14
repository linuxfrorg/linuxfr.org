# == Schema Information
# Schema version: 20090505233940
#
# Table name: users
#
#  id         :integer(4)      not null, primary key
#  name       :string(100)
#  homesite   :string(255)
#  jabber_id  :string(255)
#  role       :string(255)     default("moule"), not null
#  created_at :datetime
#  updated_at :datetime
#


# The users are the core of LinuxFr.org, its value.
# They can submit contents, vote for them, comment them...
#
# There are several levels of users:
#   * anonymous     -> they have no account and can only read public contents
#   * authenticated -> they can read public contents and submit new ones
#   * reviewer      -> they can review the news while they are in moderation
#   * moderator     -> they makes the order and the security ruling
#   * admin         -> the almighty users
#
class User < ActiveRecord::Base
  include AASM

  has_one  :account, :dependent => :destroy
  has_many :nodes
  has_many :comments
  has_many :votes, :dependent => :destroy
  has_many :relevances, :dependent => :destroy
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true

### Role ###

  named_scope :amr, :conditions => {:role => %w[admin moderator reviewer]}

  aasm_column :role
  aasm_initial_state :moule

  aasm_state :inactive
  aasm_state :moule
  aasm_state :writer
  aasm_state :reviewer
  aasm_state :moderator
  aasm_state :admin

  aasm_event :inactivate            do transitions :from => [:moule, :writer, :reviewer, :moderator, :admin], :to => [:inactive] end
  aasm_event :give_writer_rights    do transitions :from => [:moule, :reviewer],           :to => [:writer]    end
  aasm_event :give_reviewer_rights  do transitions :from => [:moule, :writer, :moderator], :to => [:reviewer]  end
  aasm_event :give_moderator_rights do transitions :from => [:reviewer, :admin],           :to => [:moderator] end
  aasm_event :give_admin_rights     do transitions :from => [:moderator],                  :to => [:admin]     end

  # An AMR is someone who is either an admin, a moderator or a reviewer
  def amr?
    admin? || moderator? || reviewer?
  end

  def active?
    role != 'inactive'
  end

### Actions ###

  def can_post_on_board?
    active?
  end

  def tag(node, tags)
    node.set_taglist(tags, self)
  end

end
