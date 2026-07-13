# encoding: UTF-8
#
# This mailer is used to notify news writers when their news are accepted or refused.
#
class NewsNotifications < ApplicationMailer
  MODERATORS = "Équipe de modération de LinuxFr.org <moderateurs@linuxfr.org>"
  EDITORS    = "Équipe de rédaction de LinuxFr.org <redacteurs@linuxfr.org>"

  def accept(news)
    send_moderation_email "Dépêche acceptée :", news
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
    send_moderation_email "Dépêche refusée :", news
  end

  def refuse_template(news, message, template)
    @news    = news
    @message = message.present? ? "La modération a tenu à ajouter : #{message}\n\n" : ""
    @response= Response.find(template)
    send_moderation_email "Dépêche refusée :", news
  end

  def refuse_en(news)
    @news = news
    send_moderation_email "Rejected news:", news
  end

  def rewrite(news)
    send_redaction_mail "Dépêche renvoyée en rédaction :", news
  end

  def followup(news, message)
    @message = message.present? ? "\n#{message}\n" : ""
    send_redaction_mail "Relance", news
  end

protected

  def send_redaction_mail(subject, news)
    @news = news
    mail from: EDITORS,
         to: EDITORS,
         bcc: news.attendees.map(&:account).compact.map(&:email),
         subject: "[LinuxFr.org] #{subject} #{news.title}"
  end

  def send_moderation_email(subject, news)
    @news = news
    headers["X-Moderator"] = news.moderator.name
    mail from: MODERATORS,
         to: news.author_email,
         cc: MODERATORS,
         subject: "[LinuxFr.org] #{subject} #{news.title}"
  end

end
