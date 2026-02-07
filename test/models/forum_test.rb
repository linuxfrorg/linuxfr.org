require "test_helper"

# == Schema Information
#
# Table name: forums
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("active"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  position    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#
class ForumTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
