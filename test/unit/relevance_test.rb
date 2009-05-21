# == Schema Information
#
# Table name: relevances
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  comment_id :integer(4)
#  vote       :boolean(1)
#  created_at :datetime
#

require 'test_helper'

class RelevanceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
