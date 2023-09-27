require 'test_helper'

class NewsNotificationsTest < ActionMailer::TestCase
  test 'accept' do
    mail = NewsNotifications.accept news(:news)

    assert_match(/Dépêche acceptée/, mail.subject)
    assert_match(/a été acceptée/, mail.body.encoded)
  end

  test 'refuse' do
    mail = NewsNotifications.refuse news(:news), 'hello world'

    assert_match(/Dépêche refusée/, mail.subject)
    assert_match(/hello world/, mail.body.encoded)
  end
end
