# encoding: utf-8
# == Schema Information
#
# Table name: responses
#
#  id      :integer          not null, primary key
#  title   :string(255)      not null
#  content :text(16777215)
#

# When a news is refused, its author is notified by an email.
# The reasons for refusing news are often the same:
# too short, already proposed, should go in forum...
# So, we keep response templates for theses emails.
#
class Response < ApplicationRecord
  validates :title, presence: { message: "Le titre est obligatoire" },
                    length: { maximum: 255, message: "Le titre est trop long" }
end
