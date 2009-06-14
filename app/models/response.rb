# == Schema Information
#
# Table name: responses
#
#  id      :integer(4)      not null, primary key
#  title   :string(255)     not null
#  content :text
#

# When a news is refused, its author is notified by an email.
# The reasons for refusing news are often the same:
# too short, already proposed, should go in forum...
# So, we keep response templates for theses emails.
#
class Response < ActiveRecord::Base
  validates_presence_of :title, :message => "Le titre est obligatoire"
end
