# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  name                :string(32)
#  homesite            :string(100)
#  jabber_id           :string(32)
#  cached_slug         :string(32)
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer(4)
#  avatar_updated_at   :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  gravatar_hash       :string(32)
#


# The users are the public informations about the people who create contents.
# See accounts for the private ones, like authentication.
#
class User < ActiveRecord::Base
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
#     set_property :field_weights => { :name => 5, :homesite => 1, :jabber_id => 1 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Avatar ###

  AVATAR_SIZE = 100
  DEFAULT_AVATAR_URL = "http://#{MY_DOMAIN}/images/default-avatar.png"

  has_attached_file :avatar, :styles      => { :thumbnail => "#{AVATAR_SIZE}x#{AVATAR_SIZE}>" },
                             :path        => ':rails_root/public/uploads/:id_partition/avatar_:style.:extension',
                             :url         => '/uploads/:id_partition/avatar_:style.:extension',
                             :default_url => DEFAULT_AVATAR_URL

end
