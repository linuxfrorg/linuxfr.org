require "test_helper"

# == Schema Information
#
# Table name: boards
#
#  id          :integer(4)      not null, primary key
#  user_agent  :string(255)
#  type        :string(255)     default("chat"), not null
#  user_id     :integer(4)
#  object_id   :integer(4)
#  object_type :string(255)
#  message     :text
#  created_at  :datetime
#
class BoardTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
