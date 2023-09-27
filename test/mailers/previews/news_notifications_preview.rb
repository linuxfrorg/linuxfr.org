# Preview all emails at http://localhost:3000/rails/mailers/news_notifications
class NewsNotificationsPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/news_notifications/accept
  def accept
    NewsNotifications.accept News.first
  end

  # Preview this email at http://localhost:3000/rails/mailers/news_notifications/refuse
  def refuse
    NewsNotifications.refuse News.first, 'hello world'
  end
end
