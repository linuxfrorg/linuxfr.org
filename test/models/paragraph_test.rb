require "test_helper"

# == Schema Information
#
# Table name: paragraphs
#
#  id          :integer(4)      not null, primary key
#  news_id     :integer(4)      not null
#  position    :integer(4)
#  second_part :boolean(1)
#  locked_by   :integer(4)
#  body        :text
#  wiki_body   :text
#
class ParagraphTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
