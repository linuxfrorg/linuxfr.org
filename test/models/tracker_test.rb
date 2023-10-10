require "test_helper"

# == Schema Information
#
# Table name: trackers
#
#  id                  :integer(4)      not null, primary key
#  state               :string(255)     default("open"), not null
#  title               :string(255)
#  cached_slug         :string(255)
#  body                :text
#  wiki_body           :text
#  category_id         :integer(4)
#  assigned_to_user_id :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#
class TrackerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
