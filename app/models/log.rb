# encoding: UTF-8
# == Schema Information
#
# Table name: logs
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  description :string(255)
#  created_at  :datetime
#  user_id     :integer
#

#
# The Log class is here to keep some facts about accounts like plonks.
#
class Log < ActiveRecord::Base
  belongs_to :account  # The account that has been modified
  belongs_to :user     # The AMR or user who made the modification
end
