# == Schema Information
# Schema version: 20090106000348
#
# Table name: nodes
#
#  id           :integer(4)      not null, primary key
#  score        :integer(4)
#  content_type :string(255)
#  content_id   :integer(4)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class Node < ActiveRecord::Base
  belongs_to :user
  belongs_to :content, :polymorphic => true
  has_many :comments
end
