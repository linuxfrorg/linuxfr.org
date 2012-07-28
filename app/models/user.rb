# encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  name              :string(32)
#  homesite          :string(100)
#  jabber_id         :string(32)
#  cached_slug       :string(32)
#  created_at        :datetime
#  updated_at        :datetime
#  avatar            :string(255)
#  signature         :string(255)
#  custom_avatar_url :string(255)
#


# The users are the public informations about the people who create contents.
# See accounts for the private ones, like authentication.
#
class User < ActiveRecord::Base
  has_one  :account, :dependent => :destroy, :inverse_of => :user
  has_many :nodes, :inverse_of => :user
  has_many :diaries, :dependent => :destroy, :inverse_of => :owner, :foreign_key => "owner_id"
  has_many :news_versions, :dependent => :nullify
  has_many :wiki_versions, :dependent => :nullify
  has_many :comments, :inverse_of => :user
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true

  attr_accessible :name, :homesite, :jabber_id, :signature, :avatar, :custom_avatar_url

### SEO ###

  extend FriendlyId
  friendly_id :login

  def login
    account ? account.login : name
  end

  def name=(name)
    super name.present? ? name : account.login
  end

### Avatar ###

  mount_uploader :avatar, AvatarUploader

  def custom_avatar_url=(url)
    if url.present?
      remove_avatar!
      self["custom_avatar_url"] = Image.new(url, "", "").src("avatars")
    else
      self["custom_avatar_url"] = nil
    end
    url
  end

  def avatar_url
    if avatar.present?
      url = avatar.url
    elsif custom_avatar_url.present?
      custom_avatar_url
    else
      url = AvatarUploader::DEFAULT_AVATAR_URL
    end
  end

end
