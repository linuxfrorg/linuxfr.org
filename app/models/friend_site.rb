# encoding: utf-8
# == Schema Information
#
# Table name: friend_sites
#
#  id       :integer          not null, primary key
#  title    :string(255)
#  url      :string(255)
#  position :integer
#

class FriendSite < ActiveRecord::Base
  acts_as_list

  default_scope order("position ASC")

  validates :title, :presence => { :message => "Le titre est obligatoire" }
  validates :url,   :presence => { :message => "L'URL est obligatoire" }
end
