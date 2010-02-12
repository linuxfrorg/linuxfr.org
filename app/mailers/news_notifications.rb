class NewsNotifications < ActionMailer::Base
  default :from => "LinuxFr.org <moderateurs@linuxfr.org>",
          :cc   => "LinuxFr.org <moderateurs@linuxfr.org>"

  def accept(news)
    send_email "Dépêche acceptée :", news
  end

  def self.refuse_with_message(news, message, template)
    if template
      refuse_template news, message, template
    elsif message == 'en'
      refuse_en news
    elsif message.present?
      refuse news, message
    end
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
