require "test_helper"

# == Schema Information
#
# Table name: posts
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("published"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  body        :text
#  wiki_body   :text
#  forum_id    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#
class PostTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
