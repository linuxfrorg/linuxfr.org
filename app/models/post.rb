# == Schema Information
# Schema version: 20090110185148
#
# Table name: posts
#
#  id         :integer(4)      not null, primary key
#  state      :string(255)     default("published"), not null
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

### Body ###

  def body
    b = body_before_type_cast
    b.blank? ? "" : WikiCreole.creole_parse(b)
  end

### ACL ###

  def editable_by?(user)
    user && (user.id == user_id || user.moderator? || user.admin?)
  end

  def deletable_by?(user)
    user && (user.moderator? || user.admin?)
  end

end
