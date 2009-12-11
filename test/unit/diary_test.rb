# == Schema Information
#
# Table name: diaries
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("published"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  owner_id    :integer(4)
#  body        :text
#  wiki_body   :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'test_helper'

class DiaryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
