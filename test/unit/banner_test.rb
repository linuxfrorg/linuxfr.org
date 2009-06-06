# == Schema Information
#
# Table name: banners
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class BannerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
