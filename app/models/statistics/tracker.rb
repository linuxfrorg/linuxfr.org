# encoding: utf-8
class Statistics::Tracker < Statistics::Statistics

  def states
    return @states if @states

    @states = { "opened" => 0, "invalid" => 0, "fixed" => 0, "total" => 0 }
    by_state = select_all("SELECT state, COUNT(*) AS cnt FROM trackers, nodes WHERE nodes.content_id=trackers.id AND nodes.content_type='Tracker' AND public=1 GROUP BY state")
    by_state.each { |state| @states[state["state"]] = state["cnt"] }
    @states["total"] = @states.values.sum

    @states
  end

  def median_time
    median = states["fixed"] / 2
    count("SELECT UNIX_TIMESTAMP(trackers.updated_at) - UNIX_TIMESTAMP(trackers.created_at) AS duration FROM trackers, nodes WHERE state='fixed' AND nodes.content_id=trackers.id AND nodes.content_type='Tracker' AND public=1 ORDER BY duration DESC LIMIT #{median},1", "duration").to_i / 86400
  end

  def average_time
    count("SELECT AVG(UNIX_TIMESTAMP(trackers.updated_at) - UNIX_TIMESTAMP(trackers.created_at)) AS avg FROM trackers, nodes WHERE state='fixed' AND nodes.content_id=trackers.id AND nodes.content_type='Tracker' AND public=1", "avg").to_i / 86400
  end

  def distinct_users
    count "SELECT COUNT(DISTINCT(user_id)) AS cnt FROM nodes WHERE content_type='Tracker' AND public=1"
  end

  def top_reporters
    select_all "SELECT name, users.cached_slug, COUNT(*) AS cnt FROM nodes JOIN users ON nodes.user_id = users.id WHERE nodes.content_type = 'Tracker' and nodes.public=1 GROUP BY user_id ORDER BY cnt DESC LIMIT 10"
  end

  def good_workers
    select_all "SELECT name, users.cached_slug, COUNT(*) AS cnt FROM trackers JOIN users ON trackers.assigned_to_user_id = users.id WHERE (state='fixed' or state='invalid') GROUP BY assigned_to_user_id ORDER BY cnt DESC"
  end

  def by_year
    return @by_year if @by_year

    @by_year = {}
    entries = select_all("SELECT YEAR(CONVERT_TZ(trackers.created_at, 'UTC', 'Europe/Paris')) AS year, state, COUNT(*) AS cnt FROM trackers, nodes WHERE nodes.content_id=trackers.id AND nodes.content_type='Tracker' AND public=1 GROUP BY year, state ORDER BY year, state")
    entries.each do |entry|
      @by_year[entry["year"]] ||= { "opened" => 0, "fixed" => 0, "invalid" => 0 }
      @by_year[entry["year"]][entry["state"]] = entry["cnt"]
    end

    @by_year
  end

  def by_month
    return @by_month if @by_month

    @by_month = {}
    entries = select_all("SELECT state, SUBSTRING(CONVERT_TZ(trackers.created_at, 'UTC', 'Europe/Paris')+0,1,6) AS created, SUBSTRING(trackers.updated_at+0,1,6) AS updated FROM trackers, nodes WHERE nodes.content_id=trackers.id AND nodes.content_type='Tracker' AND public=1")
    entries.each do |entry|
      @by_month[entry["created"]] ||= {}
      @by_month[entry["created"]]["opened"] ||= 0
      @by_month[entry["created"]]["opened"]  += 1

      if entry["state"] != "opened"
        @by_month[entry["updated"]] ||= {}
        @by_month[entry["updated"]][entry["state"]] ||= 0
        @by_month[entry["updated"]][entry["state"]]  += 1
      end
    end

    @by_month
  end

  def by_category
    select_all "SELECT categories.title AS name, COUNT(*) AS cnt FROM trackers, nodes, categories WHERE trackers.category_id = categories.id AND nodes.content_id=trackers.id AND nodes.content_type='Tracker' AND public=1 GROUP BY categories.id ORDER BY categories.title"
  end

end
