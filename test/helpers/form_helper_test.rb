require 'test_helper'

class FormHelperTest < ActionView::TestCase
  test 'should display errors' do
    news = News.new
    news.valid?

    assert_match(/<div class="errors">/, messages_on_error(news))
  end
end
