class AccountNotifications < ActionMailer::Base

  def signup(account)
    @subject = "Bienvenue sur LinuxFr.org"
    @account = account
    setup_email(account)
  end

protected

  def setup_email(account)
    subject    "[LinuxFr.org] #{@subject}"
    from       "LinuxFr.org <moderateurs@linuxfr.org>"
    recipients account.email
    sent_on    Time.now
  end

end
