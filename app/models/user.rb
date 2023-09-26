# encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  name              :string(40)
#  homesite          :string(100)
#  jabber_id         :string(32)
#  mastodon_url      :string(100)
#  cached_slug       :string(32)       not null
#  created_at        :datetime
#  updated_at        :datetime
#  avatar            :string(255)
#  signature         :string(255)
#  custom_avatar_url :string(255)
#

# The users are the public informations about the people who create contents.
# See accounts for the private ones, like authentication.
#
class User < ApplicationRecord
  has_one  :account, dependent: :destroy, inverse_of: :user
  has_many :nodes, inverse_of: :user
  has_many :diaries, dependent: :destroy, inverse_of: :owner, foreign_key: "owner_id"
  has_many :bookmarks, dependent: :destroy, inverse_of: :owner, foreign_key: "owner_id"
  has_many :news_versions, dependent: :nullify
  has_many :wiki_versions, dependent: :nullify
  has_many :comments, inverse_of: :user
  has_many :taggings, -> { includes(:tag) }, dependent: :destroy
  has_many :tags, -> { distinct }, through: :taggings

  validates_format_of :homesite, message: "L’adresse du site web personnel n’est pas valide", with: URI::regexp(%w(http https)), allow_blank: true
  validates :homesite, length: { maximum: 100, message: "L’adresse du site web personnel est trop longue" }
  validates :name, length: { maximum: 40, message: "Le nom affiché est trop long" }
  validates :jabber_id, length: { maximum: 32, message: "L’adresse XMPP est trop longue" }
  validates :mastodon_url, http_url: { protocols: ["https"], message: "L’adresse du compte Mastodon n’est pas valide" },
                           length: { maximum: 255, message: "L’adresse du compte Mastodon est trop longue" }
  validates :signature, length: { maximum: 255, message: "La signature est trop longue" }
  validates :custom_avatar_url, length: { maximum: 255, message: "L’adresse de l’avatar est trop longue" }

  def self.collective
    find_by(name: "Collectif")
  end

### SEO ###

  extend FriendlyId
  friendly_id :slug_candidates

  def slug_candidates
    [login] + (2..100).map do |i|
      "#{login}-#{i}"
    end
  end

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

  before_validation :validate_url
  def validate_url
    return if custom_avatar_url.blank?
    return if custom_avatar_url.starts_with?("//")
    errors.add(:url, "Adresse de téléchargement d’avatar non valide")
  end

  def avatar_url
    if avatar.present?
      avatar.url
    elsif custom_avatar_url.present?
      custom_avatar_url
    else
      AvatarUploader::DEFAULT_AVATAR_URL
    end
  end

end
