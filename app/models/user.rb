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
  include Canable::Cans

  has_one  :account, :dependent => :destroy, :inverse_of => :user
  has_many :nodes, :inverse_of => :user
  has_many :diaries, :dependent => :destroy, :inverse_of => :owner, :foreign_key => "owner_id"
  has_many :wiki_versions, :dependent => :nullify
  has_many :comments, :inverse_of => :user
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true

  attr_accessible :name, :homesite, :jabber_id, :avatar

### SEO ###

  has_friendly_id :login, :use_slug => true, :allow_nil => true, :reserved_words => %w(index nouveau)

  def login
    account ? account.login : name
  end

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

  scope :reviewer,  where(:role => "reviewer")
  scope :moderator, where(:role => "moderator")
  scope :admin,     where(:role => "admin")
  scope :amr,       where(:role => %w[admin moderator reviewer])

  state_machine :role, :initial => :moule do
    event :inactivate            do transition all                 => :inactive end
    event :reactivate            do transition :inactive           => :moule     end
    event :give_writer_rights    do transition [:moule, :reviewer] => :writer    end
    event :give_reviewer_rights  do transition all - :inactive     => :reviewer  end
    event :give_moderator_rights do transition [:reviewer, :admin] => :moderator end
    event :give_admin_rights     do transition :moderator          => :admin     end
  end

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
