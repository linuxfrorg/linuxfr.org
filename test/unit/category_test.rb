# == Schema Information
#
# Table name: categories
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
