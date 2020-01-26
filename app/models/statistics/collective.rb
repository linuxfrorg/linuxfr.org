# encoding: utf-8
class Statistics::Collective < Statistics::Statistics

  def contents_hash
    h = Hash.new
    Content.descendants.each {|c| h[c.to_s] = 0 }
    h
  end

  def contents_per_type
    return @contents_per_type if @contents_per_type

    @contents_per_type = contents_hash
    per_type = select_all "SELECT content_type, COUNT(*) AS cnt FROM nodes,users WHERE public=1 AND cached_slug='collectif' AND nodes.user_id=users.id GROUP BY content_type;";
    per_type.each { |content| @contents_per_type[content["content_type"]] = content["cnt"] }
    @contents_per_type["Total"] = @contents_per_type.values.sum

    @contents_per_type
  end

  def contents_per_year
    return @contents_per_year if @contents_per_year

    @contents_per_year = {}
    entries = select_all("SELECT YEAR(CONVERT_TZ(nodes.created_at, 'UTC', 'Europe/Paris')) AS year, content_type, COUNT(*) AS cnt FROM nodes,users WHERE public=1 AND cached_slug='collectif' AND nodes.user_id=users.id GROUP BY year, content_type ORDER BY year, content_type")
    entries.each do |entry|
      @contents_per_year[entry["year"]] ||= {}
      @contents_per_year[entry["year"]][entry["content_type"]] = entry["cnt"]
    end

    @contents_per_year
  end

end
