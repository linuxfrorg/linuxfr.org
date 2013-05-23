# encoding: utf-8
class Statistics::Moderation < Statistics::Statistics

  def by_day
    select_all <<-EOS
       SELECT DAYNAME(CONVERT_TZ(created_at,'+00:00','Europe/Paris')) AS d,
              WEEKDAY(CONVERT_TZ(created_at,'+00:00','Europe/Paris')) AS day,
              COUNT(*) AS cnt
         FROM nodes
        WHERE content_type='News'
     GROUP BY d
     ORDER BY day ASC
    EOS
  end

  def average_time
    select_all <<-EOS
       SELECT YEAR(CONVERT_TZ(nodes.created_at,'+00:00','Europe/Paris')) AS year,
              COUNT(*) AS cnt,
              SUM(TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at)) AS duration,
              STD(TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at)) AS std,
              MIN(TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at)) AS min,
              MAX(TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at)) AS max
         FROM nodes, news
        WHERE nodes.content_id = news.id
          AND nodes.content_type='News'
          AND nodes.created_at >= DATE('2011-01-01 00:00:001')
     GROUP BY year
     ORDER BY year
    EOS
  end

  def median_time(year, count, percentile)
    count("SELECT TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at) AS duration FROM nodes, news WHERE nodes.content_id = news.id AND nodes.content_type='News' AND YEAR(CONVERT_TZ(nodes.created_at,'+00:00','Europe/Paris'))='#{year}' ORDER BY duration LIMIT #{(count*percentile).to_i},1;", "duration")
  end

  def top_amr(sql_criterion="")
    select_all <<-EOS
       SELECT login, moderator_id, COUNT(*) AS cnt
         FROM nodes,news,accounts
        WHERE moderator_id IS NOT NULL
          AND content_id=news.id
          AND content_type='News'
          AND moderator_id=accounts.user_id
          #{sql_criterion}
    GROUP BY moderator_id
    ORDER BY LOWER(login) ASC
    EOS
  end

  def top_am
    top_amr "AND (role='moderator' OR role='admin')"
  end

  def created_on_the_last_nbdays(nbdays,prefix="")
    return "1=1" unless nbdays
    "#{prefix}created_at >= '#{nbdays.days.ago.to_s :db}'"
  end

  def nb_moderations_x_days(user_id,nbdays=nil)
    count "SELECT COUNT(*) AS cnt FROM nodes JOIN news ON nodes.content_id = news.id AND nodes.content_type='News' WHERE #{created_on_the_last_nbdays nbdays, "nodes."} AND moderator_id=#{user_id}"
  end

  def nb_editions_x_days(user_id,nbdays=nil)
    count "SELECT COUNT(*) AS cnt FROM news_versions WHERE user_id=#{user_id} AND #{created_on_the_last_nbdays nbdays}"
  end

  def nb_votes(login)
    $redis.get("users/#{login}/nb_votes").to_i
  end

  def nb_votes_last_month(login)
    $redis.keys("users/#{login}/nb_votes/*").map {|k| $redis.get(k).to_i }.sum
  end

  def moderated_news(nbdays=nil)
    count "SELECT COUNT(*) AS cnt FROM news WHERE (state='published' OR state='refused') AND #{created_on_the_last_nbdays nbdays}"
  end

  def last_news_at(user_id)
    select_all <<-EOS
      SELECT MAX(DATE(news.created_at)) AS last, TO_DAYS(now())-TO_DAYS(MAX(news.created_at)) AS days FROM news,nodes WHERE nodes.content_type='News' AND news.id=nodes.content_id AND state='published' AND user_id=#{user_id}
    EOS
  end

  def news_by_week(user_id)
    select_all <<-EOS
      SELECT COUNT(news.created_at) AS cnt, WEEK(now(),3) AS weeks FROM news,nodes WHERE nodes.content_type='News' AND news.id=nodes.content_id AND state='published' AND YEAR(news.created_at)=YEAR(now()) AND user_id=#{user_id};
    EOS
  end

  def news_by_day
    count "SELECT COUNT(*) AS cnt FROM news,nodes WHERE nodes.content_type='News' AND news.id=nodes.content_id AND state='published' AND YEAR(news.created_at)=YEAR(now());"
  end

  def amr_news_by_day
    count "SELECT COUNT(*) AS cnt FROM news,nodes,accounts WHERE nodes.content_type='News' AND news.id=nodes.content_id AND state='published' AND YEAR(news.created_at)=YEAR(now()) AND accounts.user_id=nodes.user_id AND (accounts.role='moderator' OR accounts.role='admin');"
  end
end
