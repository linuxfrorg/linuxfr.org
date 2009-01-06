# == Schema Information
# Schema version: 20090105233501
#
# Table name: users
#
#  id         :integer(4)      not null, primary key
#  login      :string(255)
#  email      :string(255)
#  name       :string(255)
#  homesite   :string(255)
#  jabber_id  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  has_many :nodes
end
