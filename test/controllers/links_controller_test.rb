require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  test "should show link" do
    links(:one).save_url_in_redis

    get "/redirect/#{links(:one).id}"

    assert_redirected_to links(:one).url
  end
end
