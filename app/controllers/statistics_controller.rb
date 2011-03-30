# encoding: UTF-8
class StatisticsController < ApplicationController

  def tracker
    by_state = ActiveRecord::Base.connection.select_all("SELECT DISTINCT state, COUNT(*) AS cnt FROM trackers GROUP BY state;")

    @states = { "opened"=>0, "invalid"=>0, "fixed"=>0, "total"=>0 }
    by_state.each do |state|
      @states[state["state"]] = state["cnt"]
      @states["total"] += state["cnt"]
    end

    median = ((@states["total"]-@states["opened"])/2.0).ceil

    @distinct_users = ActiveRecord::Base.connection.select_all("SELECT COUNT(DISTINCT(user_id)) AS cnt FROM nodes WHERE content_type='Tracker';")

    @max_entries_by_user = ActiveRecord::Base.connection.select_all("SELECT COUNT(*) AS cnt FROM nodes WHERE content_type='Tracker' GROUP BY user_id ORDER BY cnt DESC LIMIT 1;")

    @avg_time = ActiveRecord::Base.connection.select_all("SELECT IFNULL(ROUND(AVG(UNIX_TIMESTAMP(updated_at)-UNIX_TIMESTAMP(created_at))/86400),0) AS avg FROM trackers WHERE state='fixed';")

    @median_time = ActiveRecord::Base.connection.select_all("SELECT ROUND((UNIX_TIMESTAMP(updated_at)-UNIX_TIMESTAMP(created_at))/86400) AS duration FROM trackers WHERE state='fixed' ORDER BY duration ASC LIMIT \n #{median},1;")

    @good_workers = ActiveRecord::Base.connection.select_all("SELECT name, COUNT(*) AS cnt FROM trackers,users WHERE (state='fixed' or state='invalid') AND trackers.assigned_to_user_id=users.id GROUP BY assigned_to_user_id ORDER BY cnt DESC;")

    @by_year = ActiveRecord::Base.connection.select_all("SELECT YEAR(created_at) AS year, state, COUNT(*) AS cnt FROM trackers GROUP BY year,state ORDER BY year,state;")

    @by_month = {}
    entries = ActiveRecord::Base.connection.select_all("SELECT state, SUBSTRING(created_at+0,1,6) AS created, SUBSTRING(updated_at+0,1,6) AS updated FROM trackers;")
    entries.each do |entry|
      if (@by_month[entry["created"]] == nil)
        @by_month[entry["created"]] = {}
      end
      if (@by_month[entry["created"]]["opened"] == nil)
        @by_month[entry["created"]]["opened"] = 1
      else
        @by_month[entry["created"]]["opened"] += 1
      end

      if (entry["state"]!="opened")
        if (@by_month[entry["updated"]] == nil)
          @by_month[entry["updated"]] = {}
        end
        if (@by_month[entry["updated"]][entry["state"]] == nil)
          @by_month[entry["updated"]][entry["state"]] = 1
        else
          @by_month[entry["updated"]][entry["state"]] += 1
        end
      end
    end

    @by_category = ActiveRecord::Base.connection.select_all("SELECT categories.title AS name, COUNT(*) AS cnt FROM trackers,categories WHERE trackers.category_id = categories.id GROUP BY categories.id ORDER BY categories.title;")
  end

end
