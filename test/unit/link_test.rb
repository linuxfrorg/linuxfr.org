require 'test_helper'

class LinkTest < ActiveSupport::TestCase

  test "add http:// before a link if it's not the case" do
    @link = Link.new
    @link.url = 'www.yahoo.fr'
    assert_equal 'http://www.yahoo.fr', @link.url
    @link.url = 'http://www.elysee.fr'
    assert_equal 'http://www.elysee.fr', @link.url
  end

end
