# == Schema Information
#
# Table name: friend_sites
#
#  id       :integer(4)      not null, primary key
#  title    :string(255)
#  url      :string(255)
#  position :integer(4)
#

class FriendSite < ActiveRecord::Base
  acts_as_list

  scope :sorted, order("position ASC")

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :url, :message => "L'URL est obligatoire"
end
