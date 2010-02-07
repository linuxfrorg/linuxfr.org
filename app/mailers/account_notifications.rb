class AccountNotifications < ActionMailer::Base
  default :from => "LinuxFr.org <moderateurs@linuxfr.org>"

  def signup(account)
    send_email "Bienvenue sur LinuxFr.org", account
  end

  def forgot_password(account)
    send_email "Mot de passe oublié", account
  end

protected

  def send_email(subject, account)
    @account = account
    mail :to      => @account.email_address,
         :subject => "[LinuxFr.org] #{subject}"
  end

end
