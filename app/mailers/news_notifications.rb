class NewsNotifications < ActionMailer::Base
  default :from => "LinuxFr.org <moderateurs@linuxfr.org>",
          :cc   => "LinuxFr.org <moderateurs@linuxfr.org>"

  def accept(news)
    send_email "Dépêche acceptée :", news
  end

  def refuse(news, message)
    @message = message
    send_email "Dépêche refusée :", news
  end

  def refuse_template(news, message, template)
    @message = message.present? ? "Le modérateur a tenu a rajouté : #{message}\n\n" : ""
    @response= Response.find(template)
    send_email "Dépêche refusée :", news
  end

  def refuse_en(news)
    send_email "New rejected:", news
  end

protected

  def send_email(subject, news)
    @news = news
    mail :to      => news.author_email,
         :subject => "[LinuxFr.org] #{subject} #{news.title}"
  end

end
