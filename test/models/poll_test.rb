require 'test_helper'

# == Schema Information
#
# Table name: polls
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("draft"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
class PollTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test 'the truth' do
    assert true
  end
end
