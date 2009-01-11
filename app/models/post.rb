# == Schema Information
# Schema version: 20090108235238
#
# Table name: posts
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  body       :text
#  forum_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Post < Content
  belongs_to :forum

  validates_presence_of :forum, :message => "Vous devez choisir un forum"
  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Vous ne pouvez pas poster un journal vide"

  def body
    b = __send__('body_before_type_cast')
    b.blank? ? "" : WikiCreole.creole_parse(b)
  end
end
