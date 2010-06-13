# == Schema Information
#
# Table name: links
#
#  id           :integer(4)      not null, primary key
#  news_id      :integer(4)      not null
#  title        :string(255)
#  url          :string(255)
#  lang         :string(255)
#  locked_by_id :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

# The news can have some important links.
# We follow the number of clicks on each of these links.
#
class Link < ActiveRecord::Base
  belongs_to :news

  attr_accessor   :user_id
  attr_accessible :user_id, :title, :url, :lang

  validates :title, :presence => { :message => "Un lien doit obligatoirement avoir un titre" }
  validates_url_format_of :url, :message => "L'URL d'un lien n'est pas valide"

  def url=(url)
    url = "http://#{url}" if url.present? && url.not.start_with?('http')
    write_attribute :url, url
  end

### Behaviour ###

  def self.hit(id)
    url = $redis.get("links/#{id}/url")
    if url.blank?
      l = Link.find(id)
      return nil unless l
      url = l.url
      $redis.set("links/#{id}/url", url)
    end
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
      self.user_id = user.id
      self.locked_by_id = nil
      save
    end
  end

### Chat ###

  after_create :announce_create
  def announce_create
    return unless user_id
    message = render_to_string(:partial => 'redaction/links/board', :locals => {:action => 'lien ajouté', :link => self})
    news.boards.creation.create(:message => message, :user_id => user_id)
  end

  after_update :announce_update
  def announce_update
    return unless user_id
    message = render_to_string(:partial => 'redaction/links/board', :locals => {:action => 'lien modifié', :link => self})
    news.boards.edition.create(:message => message, :user_id => user_id)
  end

  before_destroy :announce_destroy
  def announce_destroy
    return unless user_id
    message = render_to_string(:partial => 'redaction/links/board', :locals => {:action => 'lien supprimé', :link => self})
    news.boards.deletion.create(:message => message, :user_id => user_id)
  end

  def lock_by(user)
    return true  if locked_by_id == user.id
    return false if locked?
    self.locked_by_id = user.id
    save
    news.boards.lock.create(:message => "<span class=\"link\" data-id=\"#{self.id}\">#{user.name} édite le lien #{title}</span>", :user_id => user.id)
    true
  end

  def locked?
    !!locked_by_id
  end
end
