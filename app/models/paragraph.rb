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

  acts_as_list :scope => [:news, :second_part]

  attr_accessible :body, :second_part

  named_scope :in_first_part,  :conditions => { :second_part => false }, :order => "position ASC"
  named_scope :in_second_part, :conditions => { :second_part => true  }, :order => "position ASC"

### Automatically split parapgraphs ###

  def self.separator
    "\n\n"
  end

  before_save :split_body
  def split_body
    bodys = body.split(self.class.separator)
    self.body = bodys.shift
    bodys.each_with_index do |b,i|
      p = self.class.create(:body => b, :second_part => second_part)
      p.insert_at(position + i + 1)
    end
  end
end
