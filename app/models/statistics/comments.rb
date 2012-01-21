# encoding: utf-8
class Statistics::Comments < Statistics::Statistics

  def comments_hash
    h = Hash.new
    Comment.descendants.each {|c| h[c.to_s] = 0 }
    h
  end

  def comments
    return @comments if @comments

    @comments = comments_hash
    by_type = select_all("SELECT content_type, COUNT(*) AS cnt FROM comments,nodes WHERE comments.node_id=nodes.id GROUP BY content_type")
    by_type.each { |comment| @comments[comment["content_type"]] = comment["cnt"] }
    @comments["Total"] = @comments.values.sum

    @comments
  end

  def comments_by_year
    return @comments_by_year if @comments_by_year

    @comments_by_year = {}
    $redis.keys("stats/comments/year/*").sort.each do |k|
      _, _, _, year, type = k.split('/')
      @comments_by_year[year] ||= comments_hash
      @comments_by_year[year][type] = $redis.get(k).to_i
    end

    @comments_by_year
  end

  def comments_by_month
    return @comments_by_month if @comments_by_month

    @comments_by_month = {}
    $redis.keys("stats/comments/month/*").sort.each do |k|
      _, _, _, month, type = k.split('/')
      @comments_by_month[month] ||= comments_hash
      @comments_by_month[month][type] = $redis.get(k).to_i
    end

    @comments_by_month
  end

  def comments_by_day
    return @comments_by_wday if @comments_by_wday

    @comments_by_wday = {}
    $redis.keys("stats/comments/wday/*").each do |k|
      @comments_by_wday[k.split('/').last] = $redis.get(k).to_i
    end

    @comments_by_wday
  end
end
