require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "should not create naked content" do
    assert_raises NotImplementedError do
      Content.create
    end
  end

  test "should get label for expand" do
    assert_equal "Lire la suite", Poll.first.label_for_expand
  end

  test "should get alternative formats" do
    assert Poll.first.alternative_formats
    assert_not Bookmark.first.alternative_formats
  end

  test "should get lastmod" do
    assert_equal polls(:one).updated_at, polls(:one).lastmod
  end

  test "should get changefreq" do
    assert_equal "hourly", polls(:one).changefreq
    polls(:draft).created_at = 2.days.ago

    assert_equal "daily", polls(:draft).changefreq
    polls(:draft).created_at = 4.days.ago

    assert_equal "monthly", polls(:draft).changefreq
    assert_equal "yearly", diaries(:old).changefreq
  end
end
