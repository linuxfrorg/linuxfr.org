class Statistics::Tracker

  def select_all(sql)
    ActiveRecord::Base.connection.select_all(sql)
  end

  def count(sql, field="cnt")
    rows = select_all(sql)
    rows.any? ? rows.first[field] : 0
  end

  def states
    return @states if @states

    @states = { "opened" => 0, "invalid" => 0, "fixed" => 0, "total" => 0 }
    by_state = select_all("SELECT state, COUNT(*) AS cnt FROM trackers GROUP BY state")
    by_state.each { |state| @states[state["state"]] = state["cnt"] }
    @states["total"] = @states.values.sum

    @states
  end

  def median_time
    median = ((states["total"] - states["opened"]) / 2.0).ceil
    count "SELECT ROUND((UNIX_TIMESTAMP(updated_at) - UNIX_TIMESTAMP(created_at)) / 86400) AS duration FROM trackers WHERE state='fixed' ORDER BY duration ASC LIMIT #{median},1", "duration"
  end

  def average_time
    count "SELECT IFNULL(ROUND(AVG(UNIX_TIMESTAMP(updated_at) - UNIX_TIMESTAMP(created_at)) / 86400),0) AS avg FROM trackers WHERE state='fixed'", "avg"
  end

  def distinct_users
    count "SELECT COUNT(DISTINCT(user_id)) AS cnt FROM nodes WHERE content_type='Tracker'"
  end

  def max_entries_by_user
    count "SELECT COUNT(*) AS cnt FROM nodes WHERE content_type='Tracker' GROUP BY user_id ORDER BY cnt DESC LIMIT 1"
  end

  def good_workers
    select_all "SELECT name, COUNT(*) AS cnt FROM trackers JOIN users ON trackers.assigned_to_user_id = users.id WHERE (state='fixed' or state='invalid') GROUP BY assigned_to_user_id ORDER BY cnt DESC"
  end

  def by_year
    return @by_year if @by_year

    @by_year = {}
    entries = select_all("SELECT YEAR(created_at) AS year, state, COUNT(*) AS cnt FROM trackers GROUP BY year, state ORDER BY year, state")
    entries.each do |entry|
      @by_year[entry["year"]] ||= { "opened" => 0, "fixed" => 0, "invalid" => 0 }
      @by_year[entry["year"]][entry["state"]] = entry["cnt"]
    end

    @by_year
  end

  def by_month
    return @by_month if @by_month

    @by_month = {}
    entries = select_all("SELECT state, SUBSTRING(created_at+0,1,6) AS created, SUBSTRING(updated_at+0,1,6) AS updated FROM trackers")
    entries.each do |entry|
      @by_month[entry["created"]] ||= {}
      @by_month[entry["created"]][entry["state"]] ||= 0
      @by_month[entry["created"]][entry["state"]]  += 1

      @by_month[entry["updated"]] ||= {}
      @by_month[entry["updated"]][entry["state"]] ||= 0
      @by_month[entry["updated"]][entry["state"]]  += 1
    end

    @by_month
  end

  def by_category
    select_all "SELECT categories.title AS name, COUNT(*) AS cnt FROM trackers, categories WHERE trackers.category_id = categories.id GROUP BY categories.id ORDER BY categories.title"
  end

end
