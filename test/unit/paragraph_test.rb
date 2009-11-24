# == Schema Information
#
# Table name: paragraphs
#
#  id          :integer(4)      not null, primary key
#  news_id     :integer(4)      not null
#  position    :integer(4)
#  second_part :boolean(1)
#  body        :text
#

require 'test_helper'

class ParagraphTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
