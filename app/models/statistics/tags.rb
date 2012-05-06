# encoding: utf-8
class Statistics::Tags < Statistics::Statistics

  def taggings_hash
    h = Hash.new
    Tag.descendants.each {|c| h[c.to_s] = 0 }
    h
  end

  def tags
    count("SELECT COUNT(*) AS cnt FROM tags", "cnt").to_i
  end

  def public_tags
    count("SELECT COUNT(*) AS cnt FROM tags WHERE public=1", "cnt").to_i
  end

  def max_taggings_count(is_public)
    count("SELECT MAX(taggings_count) AS max FROM tags WHERE public=#{is_public}", "max").to_i
  end

  def avg_taggings_count(is_public)
    count("SELECT AVG(taggings_count) AS avg FROM tags WHERE public=#{is_public}", "avg").to_i
  end

  def taggings
    return @taggings if @taggings

    @taggings = taggings_hash
    by_type = select_all("SELECT content_type, COUNT(*) AS cnt FROM taggings,nodes WHERE taggings.node_id=nodes.id GROUP BY content_type")
    by_type.each { |tagging| @taggings[tagging["content_type"]] = tagging["cnt"] }
    @taggings["Total"] = @taggings.values.sum

    @taggings
  end

  def taggings_by_year
    return @taggings_by_year if @taggings_by_year

    @taggings_by_year = {}
    entries = select_all("SELECT YEAR(taggings.created_at) AS year, content_type, COUNT(*) AS cnt FROM taggings,nodes WHERE taggings.node_id=nodes.id GROUP BY year, content_type ORDER BY year, content_type")
    entries.each do |entry|
      @taggings_by_year[entry["year"]] ||= taggings_hash
      @taggings_by_year[entry["year"]][entry["content_type"]] = entry["cnt"]
    end

    @taggings_by_year
  end

  def taggings_by_month
    return @taggings_by_month if @taggings_by_month

    @taggings_by_month = {}
    entries = select_all("SELECT CONCAT(SUBSTRING(taggings.created_at+0,1,6)) AS month, content_type, COUNT(*) AS cnt FROM taggings,nodes WHERE taggings.node_id=nodes.id AND taggings.created_at > DATE_SUB(DATE_SUB(CURDATE(),INTERVAL 1 YEAR), INTERVAL DAY(CURDATE())-1 DAY) GROUP BY month, content_type ORDER BY month ASC, content_type")
    entries.each do |entry|
      @taggings_by_month[entry["month"]] ||= taggings_hash
      @taggings_by_month[entry["month"]][entry["content_type"]] = entry["cnt"]
    end

    @taggings_by_month
  end

  def taggings_by_day
    select_all "SELECT DAYNAME(CONVERT_TZ(created_at,'+00:00','Europe/Paris')) AS d, WEEKDAY(CONVERT_TZ(created_at,'+00:00','Europe/Paris')) AS day, COUNT(*) AS cnt FROM taggings GROUP BY d ORDER BY day ASC"
  end
end
