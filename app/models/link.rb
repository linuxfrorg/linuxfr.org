# encoding: UTF-8
# == Schema Information
#
# Table name: links
#
#  id         :integer          not null, primary key
#  news_id    :integer          not null
#  title      :string(100)      not null
#  url        :string(255)      not null
#  lang       :string(2)        not null
#  created_at :datetime
#  updated_at :datetime
#

#
# The news can have some important links.
# We follow the number of clicks on each of these links.
#
class Link < ApplicationRecord
  PROTOCOLS = HTML::Pipeline::SanitizationFilter::WHITELIST[:protocols]['a']['href'] - [:relative]

  belongs_to :news

  attr_accessor :user
  Accessible = [:id, :user, :title, :url, :lang]

  validates :title, presence: { message: "Un lien doit obligatoirement avoir un titre" },
                    length: { maximum: 100, message: "Le titre est trop long" }
  validates :url, http_url: { protocols: PROTOCOLS, message: "L'adresse n'est pas valide" },
                  presence: { message: "Un lien doit obligatoirement avoir une adresse" },
                  length: { maximum: 255, message: "L’adresse est trop longue" }

  def url=(raw)
    raw.strip!
    return write_attribute :url, nil if raw.blank?
    uri = URI.parse(raw)
    if uri.scheme.blank? && uri.host.blank?
      raw = "http://#{raw}"
      uri = URI.parse(raw)
    end
    write_attribute :url, uri.to_s
  # Let raw value if error when parsed, HttpUrlValidator will manage it
  rescue URI::InvalidURIError
    write_attribute :url, raw
  end

### Behaviour ###

  def self.hit(id)
    url = $redis.get("links/#{id}/url")
    return nil if url.blank?
    $redis.incr("links/#{id}/hits")
    url
  end

  def nb_clicks
    $redis.get("links/#{self.id}/hits").to_i
  end

  def update_by(user)
    self.user = user
    if url.blank?
      destroy
    else
      save
    end
    $redis.del lock_key
  end

  after_commit :create_new_version
  def create_new_version
    news.editor ||= user.try(:account)
    news.put_paragraphs_together
    news.create_new_version
  end

  after_save :save_url_in_redis
  def save_url_in_redis
    $redis.set("links/#{self.id}/url", url)
  end

### Presentation ###

  def to_s
    "[#{lang}] #{title} : #{url}"
  end

### Push ###

  after_create :announce_create
  def announce_create
    Push.create(news, as_json.merge(kind: :add_link, nb_clicks: 0))
  end

  after_update :announce_update
  def announce_update
    Push.create(news, as_json.merge(kind: :update_link, nb_clicks: nb_clicks))
  end

  before_destroy :announce_destroy
  def announce_destroy
    Push.create(news, id: self.id, kind: :remove_link)
  end

### Lock ###

  def lock_key
    "locks/#{news.id}/l/#{self.id}"
  end

  def lock_by(user)
    return false if news.locked_for_reorg?
    locker_id = $redis.get(lock_key)
    return locker_id == user.id if locker_id
    $redis.set lock_key, user.id
    $redis.expire lock_key, 300
    true
  end

  def unlock
    $redis.del lock_key
  end

  def locked?
    !!$redis.get(lock_key)
  end

  def locked_by?(user_id)
    $redis.get(lock_key) == user_id
  end

### Presentation ###

  def locker
    User.find($redis.get lock_key).name
  end
end
