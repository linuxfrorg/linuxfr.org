# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  name                :string(100)
#  homesite            :string(255)
#  jabber_id           :string(255)
#  role                :string(255)     default("moule"), not null
#  cached_slug         :string(255)
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer(4)
#  avatar_updated_at   :datetime
#  created_at          :datetime
#  updated_at          :datetime
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
  include Canable::Cans

  has_one  :account, :dependent => :destroy, :inverse_of => :user
  has_many :nodes, :inverse_of => :user
  has_many :diaries, :dependent => :destroy, :inverse_of => :owner, :foreign_key => "owner_id"
  has_many :posts, :dependent => :destroy, :inverse_of => :owner, :foreign_key => "owner_id"
  has_many :wiki_versions, :dependent => :nullify
  has_many :comments, :inverse_of => :user
  has_many :boards, :inverse_of => :user, :dependent => :destroy
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true

  delegate :login, :email, :to => :account, :allow_nil => true

  attr_accessible :name, :homesite, :jabber_id, :avatar

### SEO ###

  has_friendly_id :login, :use_slug => true, :allow_nil => true

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes name, homesite, jabber_id
#     where "role != 'inactive'"
#     set_property :field_weights => { :name => 5, :homesite => 1, :jabber_id => 1 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Avatar ###

  has_attached_file :avatar, :styles      => { :thumbnail => "100x100>" },
                             :path        => ':rails_root/public/uploads/:id_partition/avatar_:style.:extension',
                             :url         => '/uploads/:id_partition/avatar_:style.:extension',
                             :default_url => ':gravatar_url'

  DEFAULT_AVATAR_URL = "http://#{MY_DOMAIN}/images/default-avatar.png"

  Paperclip.interpolates :gravatar_url do |attachment, style|
    attachment.instance.gravatar_url
  end

  def gravatar_url
    hash = Digest::MD5.hexdigest(account.email.downcase.strip)[0..31]
    "http://www.gravatar.com/avatar/#{hash}.jpg?size=100&d=#{CGI::escape DEFAULT_AVATAR_URL}"
  end

  def avatar_url(style, https)
    url = avatar.url(style)
    url = url.sub(/^http:\/\/www/, 'https://secure') if https
    url
  end

### Role ###

  scope :amr, where(:role => %w[admin moderator reviewer])

  aasm_column :role
  aasm_initial_state :moule

  aasm_state :inactive
  aasm_state :moule
  aasm_state :writer
  aasm_state :reviewer
  aasm_state :moderator
  aasm_state :admin

  aasm_event :inactivate            do transitions :from => [:moule, :writer, :reviewer, :moderator, :admin], :to => [:inactive] end
  aasm_event :reactivate            do transitions :from => [:inactive],                   :to => [:moule]     end
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

  def read(node)
    node.read_by(self.id)
  end

end
