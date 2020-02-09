# encoding: utf-8
class Statistics::Anonymous < Statistics::Statistics

  def contents_hash
    h = Hash.new
    Content.descendants.each {|c| h[c.to_s] = 0 }
    h
  end

  def contents_per_type
    return @contents_per_type if @contents_per_type

    @contents_per_type = contents_hash
    per_type = select_all "SELECT content_type, COUNT(*) AS cnt FROM nodes,users WHERE public=1 AND cached_slug='anonyme' AND nodes.user_id=users.id GROUP BY content_type;";
    per_type.each { |content| @contents_per_type[content["content_type"]] = content["cnt"] }
    @contents_per_type["Total"] = @contents_per_type.values.sum

    @contents_per_type
  end

  def contents_per_year
    return @contents_per_year if @contents_per_year

    @contents_per_year = {}
    entries = select_all("SELECT YEAR(CONVERT_TZ(nodes.created_at, 'UTC', 'Europe/Paris')) AS year, content_type, COUNT(*) AS cnt FROM nodes,users WHERE public=1 AND cached_slug='anonyme' AND nodes.user_id=users.id GROUP BY year, content_type ORDER BY year, content_type")
    entries.each do |entry|
      @contents_per_year[entry["year"]] ||= {}
      @contents_per_year[entry["year"]][entry["content_type"]] = entry["cnt"]
    end

    @contents_per_year
  end

  def comments_hash
    h = Hash.new
    Comment.descendants.each {|c| h[c.to_s] = 0 }
    h
  end

  def comments_per_type
    return @comments_per_type if @comments_per_type

    @comments_per_type = comments_hash
    per_type = select_all("SELECT content_type, COUNT(*) AS cnt FROM comments,nodes,users WHERE comments.node_id=nodes.id AND users.cached_slug='anonyme' AND comments.user_id=users.id GROUP BY content_type")
    per_type.each { |comment| @comments_per_type[comment["content_type"]] = comment["cnt"] }
    @comments_per_type["Total"] = @comments_per_type.values.sum

    @comments_per_type
  end

  def taggings_hash
    h = Hash.new
    Tag.descendants.each {|c| h[c.to_s] = 0 }
    h
  end

  def taggings_per_type
    return @taggings_per_type if @taggings_per_type

    @taggings_per_type = taggings_hash
    per_type = select_all("SELECT content_type, COUNT(*) AS cnt FROM taggings,nodes,users WHERE taggings.node_id=nodes.id AND users.cached_slug='anonyme' AND taggings.user_id=users.id GROUP BY content_type")
    per_type.each { |tagging| @taggings_per_type[tagging["content_type"]] = tagging["cnt"] }
    @taggings_per_type["Total"] = @taggings_per_type.values.sum

    @taggings_per_type
  end

  def taggings_per_year
    return @taggings_per_year if @taggings_per_year

    @taggings_per_year = {}
    entries = select_all("SELECT YEAR(CONVERT_TZ(taggings.created_at, 'UTC', 'Europe/Paris')) AS year, content_type, COUNT(*) AS cnt FROM taggings,nodes,users WHERE taggings.node_id=nodes.id AND users.cached_slug='anonyme' AND taggings.user_id=users.id GROUP BY year, content_type ORDER BY year, content_type")
    entries.each do |entry|
      @taggings_per_year[entry["year"]] ||= taggings_hash
      @taggings_per_year[entry["year"]][entry["content_type"]] = entry["cnt"]
    end

    @taggings_per_year
  end

end
