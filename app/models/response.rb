# encoding: utf-8
# == Schema Information
#
# Table name: responses
#
#  id      :integer          not null, primary key
#  title   :string(255)      not null
#  content :text
#

# When a news is refused, its author is notified by an email.
# The reasons for refusing news are often the same:
# too short, already proposed, should go in forum...
# So, we keep response templates for theses emails.
#
class Response < ActiveRecord::Base
  validates :title, :presence => { :message => "Le titre est obligatoire" }
end
