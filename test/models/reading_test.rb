require 'test_helper'

# == Schema Information
#
# Table name: readings
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  node_id    :integer(4)
#  updated_at :datetime
#
class ReadingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test 'the truth' do
    assert true
  end
end
