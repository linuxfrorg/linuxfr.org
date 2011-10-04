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

  after_save :save_url_in_redis
  def save_url_in_redis
    $redis.set("links/#{self.id}/url", url)
  end

### Presentation ###

  def to_s
    "[#{lang}] #{title} : #{url}"
  end

### Chat ###

  after_create :announce_create
  def announce_create
    return unless user
    message = Redaction::LinksController.new.render_to_string(:partial => 'board', :locals => {:action => 'lien ajouté', :link => self})
    Board.create_for(news, :user => user, :kind => "creation", :message => message)
  end

  after_update :announce_update
  def announce_update
    return unless user
    message = Redaction::LinksController.new.render_to_string(:partial => 'board', :locals => {:action => 'lien modifié', :link => self})
    Board.create_for(news, :user => user, :kind => "edition", :message => message)
  end

  before_destroy :announce_destroy
  def announce_destroy
    return unless user
    message = Redaction::LinksController.new.render_to_string(:partial => 'board', :locals => {:action => 'lien supprimé', :link => self})
    Board.create_for(news, :user => user, :kind => "deletion", :message => message)
  end

  def lock_by(user)
    return true  if locked_by_id == user.id
    return false if locked?
    self.locked_by_id = user.id
    save
    message = "<span class=\"link\" data-id=\"#{self.id}\">#{user.name} édite le lien #{title}</span>"
    Board.create_for(news, :user => user, :kind => "locking", :message => message)
    true
  end

  def locked?
    !!locked_by_id
  end
end
