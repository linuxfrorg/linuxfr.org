# encoding: utf-8
class Statistics::Redaction < Statistics::Statistics
  def top(sql_criterion="")
    select_all <<-EOS
      SELECT users.name, users.cached_slug, COUNT(*) AS cnt
        FROM news
        JOIN news_versions ON news.id = news_versions.news_id
        JOIN users         ON users.id = news_versions.user_id
       WHERE news_versions.created_at < news.submitted_at
       #{sql_criterion}
    GROUP BY users.id
    ORDER BY cnt DESC
       LIMIT 10
    EOS
  end

  def top_month
    top "AND news_versions.created_at >= '#{1.month.ago.to_s :db}'"
  end
end
