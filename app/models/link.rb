# encoding: UTF-8
#
# == Schema Information
#
# Table name: links
#
#  id           :integer(4)      not null, primary key
#  news_id      :integer(4)      not null
#  title        :string(100)     not null
#  url          :string(255)     not null
#  lang         :string(2)       not null
#  locked_by_id :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

# The news can have some important links.
# We follow the number of clicks on each of these links.
#
class Link < ActiveRecord::Base
  belongs_to :news

  attr_accessor   :user
  attr_accessible :user, :title, :url, :lang

  validates :title, :presence => { :message => "Un lien doit obligatoirement avoir un titre" }
  validates_format_of :url, :message => "L'URL d'un lien n'est pas valide", :with => URI::regexp(%w(http https))

  def url=(url)
    url = "http://#{url}" if url.present? && url.not.start_with?('http')
    write_attribute :url, url
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
    if url.blank?
      destroy
    else
      self.user = user
      self.locked_by_id = nil
      save
    end
  end

  after_save :create_new_version
  def create_new_version
    news.editor = user.try(:account)
    news.put_paragraphs_together
    news.create_new_version
  end

  after_save :save_url_in_redis
  def save_url_in_redis
    $redis.set("links/#{self.id}/url", url)
  end

### Presentation ###

  def to_s
    "[#{lang}] #{title} : #{url}"
  end

### Push ###

  after_create :announce_create
  def announce_create
    Push.create(news, as_json.merge(:kind => :add_link))
  end

  after_update :announce_update
  def announce_update
    Push.create(news, as_json.merge(:kind => :update_link))
  end

  before_destroy :announce_destroy
  def announce_destroy
    Push.create(news, :id => self.id, :kind => :remove_link)
  end

### Lock ###

  def lock_by(user)
    return true  if locked_by_id == user.id
    return false if locked?
    connection.update_sql "UPDATE links SET locked_by_id=#{user.id} WHERE id=#{self.id}"
    Push.create(news, :id => self.id, :username => user.name, :kind => :lock_link)
    true
  end

  def unlock
    connection.update_sql "UPDATE links SET locked_by_id=NULL WHERE id=#{self.id}"
    Push.create(news, :id => self.id, :kind => :unlock_link)
  end

  def locked?
    !!locked_by_id
  end
end
