# encoding: UTF-8
# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  title      :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#

#
# The tracker entries are categorized,
# for helping users browsing them.
#
class Category < ActiveRecord::Base
  has_many :trackers, :dependent => :nullify

  validates :title, :presence => { :message => 'Les catégories ont obligatoirement un titre' }

  default_scope order("title ASC")
end
