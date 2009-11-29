# == Schema Information
#
# Table name: paragraphs
#
#  id          :integer(4)      not null, primary key
#  news_id     :integer(4)      not null
#  position    :integer(4)
#  second_part :boolean(1)
#  body        :text
#

class Paragraph < ActiveRecord::Base
  belongs_to :news

  acts_as_list :scope => :news

  attr_accessor   :already_split
  attr_accessible :already_split, :body, :second_part

  named_scope :in_first_part,  :conditions => { :second_part => false }, :order => "position ASC"
  named_scope :in_second_part, :conditions => { :second_part => true  }, :order => "position ASC"

### Automatically split parapgraphs ###

  before_save :split_body
  def split_body
    return if already_split
    sentences = body.scan /[^\r\n]+[\r\n]*/
    self.body = sentences.pop
    sentences.each do |body|
      p = self.class.create(:body => body, :second_part => second_part, :already_split => true)
    end
  end
end
