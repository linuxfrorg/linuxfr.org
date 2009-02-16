# == Schema Information
# Schema version: 20090209232103
#
# Table name: nodes
#
#  id           :integer(4)      not null, primary key
#  content_id   :integer(4)
#  content_type :string(255)
#  score        :integer(4)      default(0)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

# The node is attached to each content.
# It helps organizing some common stuff between the contents,
# and facilitates the transformation of one content to another.
#
class Node < ActiveRecord::Base
  belongs_to :user
  belongs_to :content, :polymorphic => true
  has_many :comments
  has_many :votes, :dependent => :destroy

  named_scope :by_date, :order => "created_at DESC"

  def threads
    Threads.all(self.id)
  end
end
