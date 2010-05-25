# == Schema Information
#
# Table name: links
#
#  id           :integer(4)      not null, primary key
#  news_id      :integer(4)      not null
#  title        :string(255)
#  url          :string(255)
#  lang         :string(255)
#  nb_clicks    :integer(4)      default(0)
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

  validates_presence_of :title, :message => 'Un lien doit obligatoirement avoir un titre'
  validates_url_format_of :url, :message => "Cette URL n'est pas valide"

  def url=(url)
    url = "http://#{url}" if url.present? && url.not.start_with?('http')
    write_attribute :url, url
  end

### Behaviour ###

  def hit
    self.class.increment_counter(:nb_clicks, self.id)
    url
  end

  def update_by(user)
    if url.blank?
      destroy
    else
      self.user_id = user.id
      self.locked_by = nil
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
    return true  if locked_by == user.id
    return false if locked_by
    self.locked_by = user.id
    save
    news.boards.lock.create(:message => "<span class=\"link\" data-id=\"#{self.id}\">#{user.name} édite le lien #{title}</span>", :user_id => user.id)
    true
  end

end
