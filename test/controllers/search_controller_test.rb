require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should search" do
    get search_url

    assert_redirected_to "https://duckduckgo.com/?+site%3Alinuxfr.org"
  end
end
