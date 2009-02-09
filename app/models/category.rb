# == Schema Information
# Schema version: 20090209225424
#
# Table name: categories
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

class Category < ActiveRecord::Base
  validates_presence_of :title, :message => 'Les catégories ont obligatoirement un titre'
end
