# == Schema Information
# Schema version: 20090301003336
#
# Table name: tags
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  taggings_count :integer(4)      default(0), not null
#

class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :nodes, :through => :taggings, :uniq => true

  validates_presence_of :name
  validates_uniqueness_of :name

  named_scope :footer, :order => 'taggings_count DESC', :limit => 12
end
