require 'test_helper'

class NewsNotificationsTest < ActionMailer::TestCase
  test 'should send accept notification' do
    mail = NewsNotifications.accept news(:news)

    assert_match(/Dépêche acceptée/, mail.subject)
    assert_match(/a été acceptée/, mail.body.encoded)
  end

  test 'should send refuse notification' do
    mail = NewsNotifications.refuse news(:news), 'hello world'

    assert_match(/Dépêche refusée/, mail.subject)
    assert_match(/hello world/, mail.body.encoded)
  end

  test 'should send refuse notification with message' do
    mail = NewsNotifications.refuse_with_message news(:news), 'hello world', responses(:one).id

    assert_match(/Dépêche refusée/, mail.subject)
    assert_match(/hello world/, mail.body.encoded)

    mail = NewsNotifications.refuse_with_message news(:news), 'hello world', nil

    assert_match(/Dépêche refusée/, mail.subject)
    assert_match(/hello world/, mail.body.encoded)

    mail = NewsNotifications.refuse_with_message news(:news), 'en', nil

    assert_match(/Rejected news/, mail.subject)
  end

  test 'should send rewrite notification' do
    mail = NewsNotifications.rewrite news(:news)
    assert_match(/Dépêche renvoyée/, mail.subject)
    assert_match(/a été renvoyée/, mail.body.encoded)
  end

  test 'should send followup notification' do
    mail = NewsNotifications.followup news(:news), 'hello world'
    assert_match(/Relance/, mail.subject)
    assert_match(/hello world/, mail.body.encoded)
  end
end
