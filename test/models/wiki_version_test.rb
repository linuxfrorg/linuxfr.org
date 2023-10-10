require "test_helper"

# == Schema Information
#
# Table name: wiki_versions
#
#  id           :integer(4)      not null, primary key
#  wiki_page_id :integer(4)
#  user_id      :integer(4)
#  version      :integer(4)
#  message      :string(255)
#  body         :text
#  created_at   :datetime
#
class WikiVersionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
