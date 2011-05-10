class Statistics::Moderation

  def select_all(sql)
    ActiveRecord::Base.connection.select_all(sql)
  end

  def count(sql, field="cnt")
    rows = select_all(sql)
    rows.any? ? rows.first[field] : 0
  end

  def by_day
# TODO ?
# SET lc_time_names = 'fr_FR';
    select_all "SELECT DAYNAME(CONVERT_TZ(created_at,'+00:00','Europe/Paris')) AS d, WEEKDAY(CONVERT_TZ(created_at,'+00:00','Europe/Paris')) AS day, COUNT(*) AS cnt FROM nodes WHERE content_type='News' GROUP BY d ORDER BY day ASC;"
  end

  def average_time
    select_all "SELECT YEAR(CONVERT_TZ(nodes.created_at,'+00:00','Europe/Paris')) AS year, COUNT(*) AS cnt, SUM(TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at)) AS duration, MIN(TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at)) AS min, MAX(TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at)) AS max FROM nodes, news WHERE nodes.content_id = news.id AND nodes.content_type='News' AND nodes.created_at >= DATE('2011-01-01 00:00:001') ORDER BY year;"
  end

  def top_amr(sql_criterion)
    select_all "SELECT login, moderator_id, COUNT(*) AS cnt FROM nodes,news,accounts WHERE moderator_id IS NOT NULL AND content_id=news.id AND content_type='News' AND moderator_id=accounts.user_id #{sql_criterion} GROUP BY moderator_id ORDER BY login ASC;"
  end

  def top_am_last_month
    top_amr "AND (role='moderator' OR role='admin') AND nodes.created_at >= DATE_SUB(CURRENT_TIMESTAMP(), INTERVAL 31 DAY)"
  end

  def top_am
    top_amr "AND (role='moderator' OR role='admin')"
  end

  def top_all
    top_amr ""
  end
end
