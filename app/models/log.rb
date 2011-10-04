# encoding: UTF-8
#
# == Schema Information
#
# Table name: logs
#
#  id          :integer(4)      not null, primary key
#  account_id  :integer(4)
#  description :string(255)
#  created_at  :datetime
#  user_id     :integer(4)
#

# The Log class is here to keep some facts about accounts like plonks.
#
class Log < ActiveRecord::Base
  belongs_to :account  # The account that has been modified
  belongs_to :user     # The AMR or user who made the modification
end
