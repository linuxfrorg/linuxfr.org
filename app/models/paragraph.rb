# == Schema Information
#
# Table name: paragraphs
#
#  id          :integer(4)      not null, primary key
#  news_id     :integer(4)      not null
#  position    :integer(4)
#  second_part :boolean(1)
#  locked_by   :integer(4)
#  body        :text
#  wiki_body   :text
#

class Paragraph < ActiveRecord::Base
  belongs_to :news

  attr_accessor   :user_id, :after, :already_split
  attr_accessible :user_id, :after, :already_split, :wiki_body, :second_part, :news_id

  scope :in_first_part,  where(:second_part => false).order("position ASC")
  scope :in_second_part, where(:second_part => true ).order("position ASC")

### Automatically split parapgraphs ###

  def split_body
    wiki_body.scan /[^\r\n]+[\r\n]*/
  end

  before_validation_on_create :split_on_create
  def split_on_create
    return if already_split
    sentences = split_body
    self.wiki_body = sentences.pop
    sentences.each do |body|
      news.paragraphs.create(:wiki_body => body, :second_part => second_part, :already_split => true)
    end
  end

  before_validation_on_update :split_on_update
  def split_on_update
    sentences = split_body
    self.wiki_body = sentences.shift
    sentences.each_with_index do |body,i|
      p = news.paragraphs.create(:wiki_body => body, :second_part => second_part, :already_split => true, :user_id => user_id, :after => self.id)
      p.insert_at(position + i + 1)
    end
  end

### Behaviour ###

  def update_by(user)
    if wiki_body.blank?
      destroy
    else
      self.user_id = current_user.id
      self.locked_by = nil
      save
    end
  end

### Wikify ###

  before_save :wikify_body
  def wikify_body
    self.body = wikify(wiki_body).gsub(/<\/?p>/, '')
  end

### Chat ###

  after_create :announce_create
  def announce_create
    return unless user_id
    message = render_to_string(:partial => 'redaction/paragraphs/board', :locals => {:action => 'paragraphe ajouté', :paragraph => self})
    news.boards.creation.create(:message => message, :user_id => user_id)
    self.user_id = nil
  end

  after_update :announce_update
  def announce_update
    return unless user_id
    message = render_to_string(:partial => 'redaction/paragraphs/board', :locals => {:action => 'paragraphe modifié', :paragraph => self})
    news.boards.edition.create(:message => message, :user_id => user_id)
    self.user_id = nil
  end

  before_destroy :announce_destroy
  def announce_destroy
    return unless user_id
    message = render_to_string(:partial => 'redaction/paragraphs/board', :locals => {:action => 'paragraphe supprimé', :paragraph => self})
    news.boards.deletion.create(:message => message, :user_id => user_id)
    self.user_id = nil
  end

  # Warning, acts_as_list also declares a before_destroy callback,
  # and this callback must be called after +announce_destroy+.
  # So do NOT move this line upper in this file.
  acts_as_list :scope => :news

  def lock_by(user)
    return true  if locked_by == user.id
    return false if locked_by
    self.locked_by = user.id
    save
    news.boards.lock.create(:message => "<span class=\"paragraph\" data-id=\"#{self.id}\">#{user.name} édite le paragraph #{wiki_body[0,20]}</span>", :user_id => user.id)
    true
  end

### Presentation ###

  def part
    second_part ? 'second_part' : 'first_part'
  end

end
