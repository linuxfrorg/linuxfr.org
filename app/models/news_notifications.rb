class NewsNotifications < ActionMailer::Base

  def accept(news)
    @subject = "Dépêche acceptée : #{news.title}"
    @news    = news
    setup_email
  end

  def refuse(news)
    @subject = "Dépêche refusée : #{news.title}"
    @news    = news
    setup_email
  end

protected

  def setup_email
    subject    "[LinuxFr.org] #{@subject}"
    from       "LinuxFr.org <moderateurs@linuxfr.org>"
    recipients @news.author_email
    cc         "LinuxFr.org <moderateurs@linuxfr.org>"
    sent_on    Time.now
  end

end
