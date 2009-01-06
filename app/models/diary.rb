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

class Diary < ActiveRecord::Base
  has_one :node, :as => :content, :dependent => :destroy

  named_scope :ordered, :order => "created_at DESC"

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Vous ne pouvez pas poster un journal vide"
end
