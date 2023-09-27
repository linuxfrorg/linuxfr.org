require 'test_helper'

# == Schema Information
#
# Table name: wiki_pages
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("public"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  body        :text
#  created_at  :datetime
#  updated_at  :datetime
#
class WikiPageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test 'the truth' do
    assert true
  end
end
