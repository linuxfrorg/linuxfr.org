require "test_helper"

# == Schema Information
#
# Table name: news
#
#  id           :integer(4)      not null, primary key
#  state        :string(255)     default("draft"), not null
#  title        :string(255)
#  cached_slug  :string(255)
#  body         :text
#  second_part  :text
#  moderator_id :integer(4)
#  section_id   :integer(4)
#  author_name  :string(255)     default("anonymous"), not null
#  author_email :string(255)     default("anonymous@dlfp.org"), not null
#  created_at   :datetime
#  updated_at   :datetime
#
class NewsTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
