require 'test_helper'

class NewsNotificationsTest < ActionMailer::TestCase
  test "accept" do
    @expected.subject = 'NewsNotifications#accept'
    @expected.body    = read_fixture('accept')
    @expected.date    = Time.now

    assert_equal @expected.encoded, NewsNotifications.create_accept(@expected.date).encoded
  end

  test "refuse" do
    @expected.subject = 'NewsNotifications#refuse'
    @expected.body    = read_fixture('refuse')
    @expected.date    = Time.now

    assert_equal @expected.encoded, NewsNotifications.create_refuse(@expected.date).encoded
  end

end
