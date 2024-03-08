# encoding: utf-8
class Statistics::Moderation < Statistics::Statistics

  def by_day
    select_all <<-EOS
       SELECT content_type AS type,
              DAYNAME(CONVERT_TZ(created_at,'UTC','Europe/Paris')) AS d,
              WEEKDAY(CONVERT_TZ(created_at,'UTC','Europe/Paris')) AS day,
              COUNT(*) AS cnt
         FROM nodes
        WHERE (content_type='News' or content_type='Poll') AND public=1
     GROUP BY type, d, day
     ORDER BY type ASC, day ASC
    EOS
  end

  ACTS_OF_MODERATION = ['Interdiction de tribune', 'a donné 50 points de karma', 'Interdiction de poster des commentaires']

  def acts_by_year
    return @acts_by_year if @acts_by_year

    @acts_by_year = {}

    ACTS_OF_MODERATION.each do |log|
      entries = acts_by_year_and_log(log)
      entries.each do |entry|
        @acts_by_year[entry["year"]] ||= {}
        @acts_by_year[entry["year"]][log] = entry["cnt"]
      end
    end
  end

  def acts_by_year_and_log(log)
    select_all("SELECT YEAR(CONVERT_TZ(created_at,'UTC','Europe/Paris')) AS year, COUNT(*) AS cnt FROM logs WHERE description LIKE '%#{log}%' GROUP BY year ORDER BY year;")
  end

  def nb_acts_x_days(user_id,nbdays=nil)
    count "SELECT COUNT(*) AS cnt FROM logs WHERE (#{ACTS_OF_MODERATION.map { |log| "description LIKE '%#{log}%'" }.join(' OR ')}) AND #{created_on_the_last_nbdays nbdays, "logs."} AND user_id=#{user_id}"
  end

  def average_time
    select_all <<-EOS
       SELECT YEAR(CONVERT_TZ(nodes.created_at,'UTC','Europe/Paris')) AS year,
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
    count("SELECT TIMESTAMPDIFF(SECOND,news.created_at,nodes.created_at) AS duration FROM nodes, news WHERE nodes.content_id = news.id AND nodes.content_type='News' AND YEAR(CONVERT_TZ(nodes.created_at,'UTC','Europe/Paris'))='#{year}' ORDER BY duration LIMIT #{(count*percentile).to_i},1;", "duration")
  end

  def top_amr(sql_criterion="")
    select_all <<-EOS
       SELECT name, users.cached_slug, login, moderator_id, COUNT(*) AS cnt
         FROM nodes, news, users
         LEFT JOIN accounts ON accounts.user_id=users.id
        WHERE moderator_id IS NOT NULL
          AND content_id=news.id
          AND content_type='News'
          AND moderator_id=users.id
          #{sql_criterion}
    GROUP BY name, users.cached_slug, login, moderator_id
    ORDER BY LOWER(login) ASC
    EOS
  end

  def top_am
    top_amr "AND (role='moderator' OR role='admin')"
  end

  def created_on_the_last_nbdays(nbdays,prefix="")
    return "1=1" unless nbdays
    "#{prefix}created_at >= '#{nbdays.days.ago.to_fs :db}'"
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
      SELECT COUNT(news.created_at) AS cnt, WEEK(now(),3) AS weeks FROM news,nodes WHERE nodes.content_type='News' AND news.id=nodes.content_id AND state='published' AND YEAR(CONVERT_TZ(news.created_at,'UTC','Europe/Paris'))=YEAR(now()) AND user_id=#{user_id};
    EOS
  end

  def news_by_day
    count "SELECT COUNT(*) AS cnt FROM news,nodes WHERE nodes.content_type='News' AND news.id=nodes.content_id AND state='published' AND YEAR(CONVERT_TZ(news.created_at,'UTC','Europe/Paris'))=YEAR(now());"
  end

  def amr_news_by_day
    count "SELECT COUNT(*) AS cnt FROM news,nodes,accounts WHERE nodes.content_type='News' AND news.id=nodes.content_id AND state='published' AND YEAR(CONVERT_TZ(news.created_at,'UTC','Europe/Paris'))=YEAR(now()) AND accounts.user_id=nodes.user_id AND (accounts.role='moderator' OR accounts.role='admin');"
  end
end
