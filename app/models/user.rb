# == Schema Information
# Schema version: 20090505233940
#
# Table name: users
#
#  id         :integer(4)      not null, primary key
#  login      :string(40)      not null
#  name       :string(100)
#  homesite   :string(255)
#  jabber_id  :string(255)
#  role       :string(255)     default("moule"), not null
#  state      :string(255)     default("passive"), not null
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
  has_one  :account, :dependent => :destroy
  has_many :nodes
  has_many :comments
  has_many :votes, :dependent => :destroy
  has_many :relevances, :dependent => :destroy
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true

### Informations ###

  def public_name
    name || login
  end

### Role ###

  # An AMR is someone who is either an admin, a moderator or a reviewer
  def amr?
    admin? || moderator? || reviewer?
  end

  # Return the number of people who are either admin, moderator or reviewer
  def self.count_amr
    count(:conditions => {:role => %w[admin moderator reviewer]})
  end

  def admin?
    role == "admin"
  end

  def moderator?
    role == "moderator"
  end

  def reviewer?
    role == "reviewer"
  end

  def writer?
    role == "writer"
  end

### Actions ###

  # TODO move this method to account
  def can_post_on_board?
    true # TODO
  end

  def tag(node, tags)
    node.set_taglist(tags, self)
  end

end
