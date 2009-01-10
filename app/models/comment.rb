# == Schema Information
# Schema version: 20090110185148
#
# Table name: comments
#
#  id         :integer(4)      not null, primary key
#  node_id    :integer(4)
#  user_id    :integer(4)
#  title      :string(255)
#  body       :text
#  parent_id  :integer(4)
#  lft        :integer(4)
#  rgt        :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :node

  acts_as_nested_set :scope => :node

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Vous ne pouvez pas poster un commentaire vide"
end
