# == Schema Information
#
# Table name: tags
#
#  id             :integer(4)      not null, primary key
#  name           :string(64)      not null
#  taggings_count :integer(4)      default(0), not null
#

class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy, :inverse_of => :tag
  has_many :nodes, :through => :taggings, :uniq => true

  validates :name, :presence => true, :uniqueness => true

  scope :footer, order('taggings_count DESC').limit(12)
end
