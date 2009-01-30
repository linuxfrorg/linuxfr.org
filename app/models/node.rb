# == Schema Information
# Schema version: 20090120005239
#
# Table name: nodes
#
#  id           :integer(4)      not null, primary key
#  content_type :string(255)
#  content_id   :integer(4)
#  score        :integer(4)      default(0)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class Node < ActiveRecord::Base
  belongs_to :user
  belongs_to :content, :polymorphic => true
  has_many :comments
  has_many :votes, :dependent => :destroy

  named_scope :by_date, :order => "created_at DESC"
end
