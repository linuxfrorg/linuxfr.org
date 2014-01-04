# encoding: utf-8
class Statistics::Redaction < Statistics::Statistics
  def top(sql_criterion="", limit=10)
    select_all <<-EOS
      SELECT users.name, users.cached_slug, COUNT(*) AS cnt
        FROM news
        JOIN news_versions ON news.id = news_versions.news_id
        JOIN users         ON users.id = news_versions.user_id
       WHERE news_versions.created_at < news.submitted_at
             #{sql_criterion}
    GROUP BY users.id
    ORDER BY cnt DESC
       LIMIT #{limit}
    EOS
  end

  def top_month(limit=10)
    top "AND news_versions.created_at >= '#{1.month.ago.to_s :db}'", limit
  end

  def top_week(limit=10)
    top "AND news_versions.created_at >= '#{7.days.ago.to_s :db}'", limit
  end

  def top_created(nb_days, limit)
    select_all <<-EOS
      SELECT users.name, users.cached_slug, COUNT(*) AS cnt
        FROM news
        JOIN nodes ON news.id = nodes.content_id AND nodes.content_type = 'News'
        JOIN users ON users.id = nodes.user_id
       WHERE news.created_at >= '#{nb_days.days.ago.to_s :db}'
    GROUP BY users.id
    ORDER BY cnt DESC
       LIMIT #{limit}
    EOS
  end

  def top_edited(nb_days, limit)
    select_all <<-EOS
      SELECT users.name, users.cached_slug, COUNT(DISTINCT news_id) AS cnt
        FROM users
        JOIN news_versions ON users.id = news_versions.user_id
       WHERE news_versions.created_at >= '#{nb_days.days.ago.to_s :db}'
    GROUP BY users.id
    ORDER BY cnt DESC
       LIMIT #{limit}
    EOS
  end
end
