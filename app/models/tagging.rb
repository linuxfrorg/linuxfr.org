# encoding: utf-8
# == Schema Information
#
# Table name: taggings
#
#  id         :integer          not null, primary key
#  tag_id     :integer          not null
#  node_id    :integer          not null
#  user_id    :integer
#  created_at :datetime
#

class Tagging < ActiveRecord::Base
  belongs_to :tag, counter_cache: true
  belongs_to :node
  belongs_to :user, optional: true

  validates_uniqueness_of :tag_id, :scope => [:node_id, :user_id]
  validates :tag_id, presence: true

  scope :owned_by, ->(user_id) { where(user_id: user_id).order(created_at: :desc) }
end
