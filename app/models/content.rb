class Content < ActiveRecord::Base
  self.abstract_class = true

  has_one :node, :as => :content, :dependent => :destroy
  has_one :user, :through => :node
  has_many :comments, :through => :node

  named_scope :sorted, :order => "created_at DESC"
end
