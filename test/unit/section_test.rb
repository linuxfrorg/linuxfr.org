# == Schema Information
#
# Table name: sections
#
#  id         :integer(4)      not null, primary key
#  state      :string(255)     default("published"), not null
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class SectionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
