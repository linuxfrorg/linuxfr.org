require "test_helper"

# == Schema Information
#
# Table name: poll_answers
#
#  id         :integer(4)      not null, primary key
#  poll_id    :integer(4)
#  answer     :string(255)
#  votes      :integer(4)      default(0), not null
#  position   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#
class PollAnswerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
