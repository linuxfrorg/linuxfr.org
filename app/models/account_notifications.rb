class AccountNotifications < ActionMailer::Base

  def signup(account)
    @subject = "Bienvenue sur LinuxFr.org"
    @account = account
    setup_email
  end

  def forgot_password(account)
    @subject = "Mot de passe oublié"
    @account = account
    setup_email
  end

protected

  def setup_email
    subject    "[LinuxFr.org] #{@subject}"
    from       "LinuxFr.org <moderateurs@linuxfr.org>"
    recipients @account.email_address
    sent_on    Time.now
  end

end
