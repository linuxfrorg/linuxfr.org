require 'test_helper'

# == Schema Information
#
# Table name: tags
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  taggings_count :integer(4)      default(0), not null
#
class TagTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test 'the truth' do
    assert true
  end
end
