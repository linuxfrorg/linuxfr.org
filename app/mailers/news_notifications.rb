# encoding: UTF-8
#
# This mailer is used to notify news writers when their news are accepted or refused.
#
class NewsNotifications < ActionMailer::Base
  default :from => "LinuxFr.org <moderateurs@linuxfr.org>",
          :cc   => "LinuxFr.org <moderateurs@linuxfr.org>"

  def accept(news)
    send_email "Dépêche acceptée :", news
  end

  def self.refuse_with_message(news, message, template)
    if template
      refuse_template news, message, template
    elsif message == 'no'
      nil
    elsif message == 'en'
      refuse_en news
    elsif message.present?
      refuse news, message
    end
  end

  def refuse(news, message)
    @news    = news
    @message = message
    send_email "Dépêche refusée :", news
  end

  def refuse_template(news, message, template)
    @news    = news
    @message = message.present? ? "Le modérateur a tenu à ajouter : #{message}\n\n" : ""
    @response= Response.find(template)
    send_email "Dépêche refusée :", news
  end

  def refuse_en(news)
    @news = news
    send_email "Rejected news:", news
  end

protected

  def send_email(subject, news)
    @news = news
    headers["X-Moderator"] = news.moderator.name
    mail :to      => news.author_email,
         :subject => "[LinuxFr.org] #{subject} #{news.title}"
  end

end
