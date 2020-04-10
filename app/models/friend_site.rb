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

  default_scope { order(position: :asc) }

  validates :title, presence: { message: "Le titre est obligatoire" },
                    length: { maximum: 255, message: "Le titre est trop long" }
  validates :url,   presence: { message: "L’URL est obligatoire" },
                    length: { maximum: 255, message: "L’URL est trop longue" }
end
