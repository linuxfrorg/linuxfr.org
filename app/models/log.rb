# encoding: UTF-8
#
# == Schema Information
#
# Table name: accounts
#
#  id                   :integer(4)      not null, primary key
#  account_id           :integer(4)
#  description          :string(255)
#

# The Log class is here to keep some facts about accounts like blacklist.
#
class Log < ActiveRecord::Base
  belongs_to :account
end
