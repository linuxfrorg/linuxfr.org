# encoding: utf-8
class Statistics::Contents < Statistics::Statistics

  def contents_hash
    h = Hash.new
    Content.descendants.each {|c| h[c.to_s] = 0 }
    h
  end

  def contents
    return @contents if @contents

    @contents = contents_hash
    by_type = select_all "SELECT content_type, COUNT(*) AS cnt FROM nodes WHERE public=1 GROUP BY content_type;";
    by_type.each { |content| @contents[content["content_type"]] = content["cnt"] }
    @contents["Total"] = @contents.values.sum

    @contents
  end

  def news
    return @news if @news

    @news = { "candidate" => 0, "draft" => 0, "published" => 0, "refused" => 0 }
    by_state = select_all "SELECT state, COUNT(*) AS cnt FROM news GROUP BY state;";
    by_state.each { |state| @news[state["state"]] = state["cnt"] }

    @news
  end

  def nb_news_authors
    count "SELECT COUNT(DISTINCT(author_name)) AS cnt FROM news WHERE state='published'"
  end

  def nb_news_accounts
    count "SELECT COUNT(DISTINCT(user_id)) AS cnt FROM nodes, news WHERE nodes.content_id=news.id AND content_type='News' AND news.state='published'"
  end

  def contents_by_year
    return @contents_by_year if @contents_by_year

    @contents_by_year = {}
    entries = select_all("SELECT YEAR(created_at) AS year, content_type, COUNT(*) AS cnt FROM nodes WHERE public=1 GROUP BY year, content_type ORDER BY year, content_type")
    entries.each do |entry|
      @contents_by_year[entry["year"]] ||= contents_hash
      @contents_by_year[entry["year"]][entry["content_type"]] = entry["cnt"]
    end

    @contents_by_year
  end

  def contents_by_month
    return @contents_by_month if @contents_by_month

    @contents_by_month = {}
    entries = select_all("SELECT CONCAT(SUBSTRING(created_at+0,1,6)) AS month, content_type, COUNT(*) AS cnt FROM nodes WHERE created_at > DATE_SUB(DATE_SUB(CURDATE(),INTERVAL 1 YEAR), INTERVAL DAY(CURDATE())-1 DAY) AND public=1 GROUP BY month, content_type ORDER BY month ASC, content_type")
    entries.each do |entry|
      @contents_by_month[entry["month"]] ||= contents_hash
      @contents_by_month[entry["month"]][entry["content_type"]] = entry["cnt"]
    end

    @contents_by_month
  end

  def contents_by_day
    select_all "SELECT DAYNAME(CONVERT_TZ(created_at,'+00:00','Europe/Paris')) AS d, WEEKDAY(CONVERT_TZ(created_at,'+00:00','Europe/Paris')) AS day, COUNT(*) AS cnt FROM nodes WHERE public=1 GROUP BY d ORDER BY day ASC"
  end

  def news_size
    select_all "SELECT YEAR(created_at) AS year,ROUND(AVG(LENGTH(body)+LENGTH(second_part))) AS cnt FROM news WHERE state='published' GROUP BY year ORDER BY year"
  end

  def contents_by_license
    return @contents_by_license if @contents_by_license

    @contents_by_license = {}
    entries = select_all "SELECT YEAR(created_at) AS year, content_type, ROUND(AVG(100*cc_licensed)) AS pct FROM nodes WHERE (content_type='News' OR content_type='Diary') AND public=1 GROUP BY year, content_type HAVING year>=2010 ORDER BY year, content_type;"
    entries.each do |entry|
      @contents_by_license[entry["year"]] ||= contents_hash
      @contents_by_license[entry["year"]][entry["content_type"]] = entry["pct"]
    end

    @contents_by_license
  end
end
