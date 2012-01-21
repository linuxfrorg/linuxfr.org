# encoding: utf-8
# == Schema Information
# Schema version: 20090301003336
#
# Table name: taggings
#
#  id         :integer(4)      not null, primary key
#  tag_id     :integer(4)
#  node_id    :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#

class Tagging < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :node
  belongs_to :user

  scope :owned_by, lambda { |user_id| where(:user_id => user_id).order("created_at DESC") }
end
