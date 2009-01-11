# == Schema Information
# Schema version: 20090106000348
#
# Table name: diaries
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

class Diary < Content
  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Vous ne pouvez pas poster un journal vide"

  def body
    b = __send__('body_before_type_cast')
    b.blank? ? "" : WikiCreole.creole_parse(b)
  end
end
