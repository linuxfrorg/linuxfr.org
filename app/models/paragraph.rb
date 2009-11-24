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
    bodys = body.scan /[^\n]+\n*/
    self.body = bodys.shift
    add_to_list_bottom unless position
    bodys.each_with_index do |b,i|
      p = self.class.create(:body => b, :second_part => second_part, :already_split => true)
      p.insert_at(position + i + 1)
    end
  end
end
