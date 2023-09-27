require 'test_helper'

# == Schema Information
#
# Table name: taggings
#
#  id         :integer(4)      not null, primary key
#  tag_id     :integer(4)
#  node_id    :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#
class TaggingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test 'the truth' do
    assert true
  end
end
