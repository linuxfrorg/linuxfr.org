require 'test_helper'

class AccountNotificationsTest < ActionMailer::TestCase
  test "signup" do
    @expected.subject = 'AccountNotifications#signup'
    @expected.body    = read_fixture('signup')
    @expected.date    = Time.now

    assert_equal @expected.encoded, AccountNotifications.create_signup(@expected.date).encoded
  end

end
