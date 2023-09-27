require 'test_helper'

# == Schema Information
#
# Table name: links
#
#  id         :integer(4)      not null, primary key
#  news_id    :integer(4)      not null
#  title      :string(255)
#  url        :string(255)
#  lang       :string(255)
#  nb_clicks  :integer(4)      default(0)
#  locked_by  :integer(4)
#  created_at :datetime
#  updated_at :datetime
#
class LinkTest < ActiveSupport::TestCase
  test "add http:// before a link if it's not the case" do
    @link = Link.new
    @link.url = 'www.yahoo.fr'
    assert_equal 'http://www.yahoo.fr', @link.url
    @link.url = 'http://www.elysee.fr'
    assert_equal 'http://www.elysee.fr', @link.url
  end
end
