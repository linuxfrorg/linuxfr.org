# encoding: UTF-8
#
# == Schema Information
#
# Table name: accounts
#
#  id                   :integer(4)      not null, primary key
#  account_id           :integer(4)
#  description          :string(255)
#  user_id              :integer(4)
#  created_at           :datetime
#

# The Log class is here to keep some facts about accounts like plonks.
#
class Log < ActiveRecord::Base
  belongs_to :account  # The account that has been modified
  belongs_to :user     # The AMR or user who made the modification
end
