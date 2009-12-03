# == Schema Information
#
# Table name: paragraphs
#
#  id          :integer(4)      not null, primary key
#  news_id     :integer(4)      not null
#  position    :integer(4)
#  second_part :boolean(1)
#  body        :text
#  wiki_body   :text
#

class Paragraph < ActiveRecord::Base
  belongs_to :news

  acts_as_list :scope => :news

  attr_accessor   :user_id, :already_split
  attr_accessible :user_id, :already_split, :wiki_body, :second_part, :news_id

  named_scope :in_first_part,  :conditions => { :second_part => false }, :order => "position ASC"
  named_scope :in_second_part, :conditions => { :second_part => true  }, :order => "position ASC"

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
      # TODO user_id
    end
  end

  before_validation_on_update :split_on_update
  def split_on_update
    sentences = split_body
    self.wiki_body = sentences.shift
    sentences.each_with_index do |body,i|
      p = news.paragraphs.create(:wiki_body => body, :second_part => second_part, :already_split => true, :user_id => user_id)
      p.insert_at(position + i + 1)
    end
  end

### Wikify ###

  before_save :wikify_body
  def wikify_body
    self.body = wikify(wiki_body)
  end

### Chat ###

  after_save :announce
  def announce
    return unless user_id
    news.boards.edition.create(:message => wiki_body, :user_id => user_id)
    self.user_id = nil
  end

### Presentation ###

  def part
    second_part ? 'second_part' : 'first_part'
  end

end
