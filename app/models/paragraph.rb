# encoding: UTF-8
#
# == Schema Information
#
# Table name: paragraphs
#
#  id           :integer(4)      not null, primary key
#  news_id      :integer(4)      not null
#  position     :integer(4)
#  second_part  :boolean(1)
#  locked_by_id :integer(4)
#  body         :text
#  wiki_body    :text
#

# A paragraph is a block of text from a news, with wiki syntax.
# The paragraph never modifies the body (or wiki_body) of a news,
# only the news known its state and when to do the synchronization!
#
# A paragraph can be split in several if it has a blank line in its body.
#
class Paragraph < ActiveRecord::Base
  include ERB::Util

  belongs_to :news

  attr_accessor   :user, :after, :already_split
  attr_accessible :user, :after, :already_split, :wiki_body, :second_part, :news_id

  scope :in_first_part,  where(:second_part => false).order("position ASC")
  scope :in_second_part, where(:second_part => true ).order("position ASC")

### Automatically split paragraphs ###

  # Split body in paragraphs, but preserve code!
  def split_body
    return [] if wiki_body.blank?

    parts   = []
    codemap = {}
    str = wiki_body.gsub(/^``` ?(.+?)\r?\n(.+?)\r?\n```\r?$/m) do
      id = Digest::SHA1.hexdigest($2)
      codemap[id] = $&.chomp
      id + "\n"
    end

    until str.empty?
      left, sep, str = str.partition(/(\r?\n){2}/)
      left.sub!(/\A(\r?\n)+/, '')
      codemap.each { |id,code| left.gsub!(id, code) }
      parts << left + sep
    end

    parts
  end

  before_validation :split_on_create, :on => :create
  def split_on_create
    return if already_split
    sentences = split_body
    self.wiki_body = sentences.pop
    sentences.each do |body|
      news.paragraphs.create(:wiki_body => body, :second_part => second_part, :already_split => true)
    end
  end

  before_validation :split_on_update, :on => :update
  def split_on_update
    sentences = split_body
    self.wiki_body = sentences.shift
    sentences.reverse.each_with_index do |body,i|
      p = news.paragraphs.create(:wiki_body => body, :second_part => second_part, :already_split => true, :user => user, :after => self.id)
      p.insert_at(position + 1)
    end
  end

### Behaviour ###

  def update_by(user)
    if wiki_body.blank?
      destroy
    else
      self.user = user
      self.locked_by_id = nil
      save
    end
    news.body_will_change!
    news.save
  end

### Wikify ###

  before_save :wikify_body
  def wikify_body
    self.body = wikify(wiki_body).gsub(/<\/?p>/, '')
  end

  sanitize_attr :body

### Chat ###

  after_create :announce_create
  def announce_create
    return unless user
    message = Redaction::ParagraphsController.new.render_to_string(:partial => 'board', :locals => {:action => 'paragraphe ajouté', :paragraph => self})
    Board.create_for(news, :user => user, :kind => "creation", :message => message)
    self.user = nil
  end

  after_update :announce_update
  def announce_update
    return unless user
    message = Redaction::ParagraphsController.new.render_to_string(:partial => 'board', :locals => {:action => 'paragraphe modifié', :paragraph => self})
    Board.create_for(news, :user => user, :kind => "edition", :message => message)
    self.user = nil
  end

  before_destroy :announce_destroy
  def announce_destroy
    return unless user
    message = Redaction::ParagraphsController.new.render_to_string(:partial => 'board', :locals => {:action => 'paragraphe supprimé', :paragraph => self})
    Board.create_for(news, :user => user, :kind => "deletion", :message => message)
    self.user = nil
  end

  # Warning, acts_as_list also declares a before_destroy callback,
  # and this callback must be called after +announce_destroy+.
  # So do NOT move this line upper in this file.
  acts_as_list :scope => :news

  def lock_by(user)
    return true  if locked_by_id == user.id
    return false if locked?
    self.locked_by_id = user.id
    save
    message = "<span class=\"paragraph\" data-id=\"#{self.id}\">#{user.name} édite le paragraphe #{html_escape wiki_body[0,20]}</span>"
    Board.create_for(news, :user => user, :kind => "locking", :message => message)
    true
  end

  def locked?
    !!locked_by_id
  end

### Presentation ###

  def part
    second_part ? 'second_part' : 'first_part'
  end
end
