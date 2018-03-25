# encoding: utf-8
class Statistics::Applications < Statistics::Statistics

  def applications
    count("SELECT COUNT(*) AS cnt FROM oauth_applications", "cnt").to_i
  end

  def applications_distinct_owners
    count("SELECT COUNT(DISTINCT(owner_id)) AS cnt FROM oauth_applications", "cnt").to_i
  end

  def access_grants
    count("SELECT COUNT(*) AS cnt FROM oauth_access_grants", "cnt").to_i
  end

  def access_grants_distinct_applications
    count("SELECT COUNT(DISTINCT(application_id)) AS cnt FROM oauth_access_grants", "cnt").to_i
  end

  def access_tokens
    return @access_tokens if @access_tokens

    @access_tokens = { "00" => 0, "10" => 0, "11" => 0, "total" => 0 }
    by_state = select_all("SELECT COUNT(*) AS cnt, CONCAT((created_at+expires_in<now()), (IFNULL(revoked_at,now()+'1 year') < now())) AS expired_revoked FROM oauth_access_tokens GROUP BY expired_revoked")
    by_state.each { |access_token| @access_tokens[access_token["expired_revoked"]] = access_token["cnt"] }
    @access_tokens["total"] = @access_tokens.values.sum

    @access_tokens
  end

  def access_tokens_distinct_applications
    count("SELECT COUNT(DISTINCT(application_id)) AS cnt FROM oauth_access_tokens", "cnt").to_i
  end

  def applications_by_year
    return @applications_by_year if @applications_by_year

    @applications_by_year = {}
    entries = select_all("SELECT YEAR(oauth_applications.created_at) AS year, COUNT(*) AS cnt FROM oauth_applications GROUP BY year ORDER BY year")
    entries.each do |entry|
      @applications_by_year[entry["year"]] = entry["cnt"]
    end

    @applications_by_year
  end

  def access_grants_by_year
    return @access_grants_by_year if @access_grants_by_year

    @access_grants_by_year = {}
    entries = select_all("SELECT YEAR(oauth_access_grants.created_at) AS year, COUNT(*) AS cnt FROM oauth_access_grants GROUP BY year ORDER BY year")
    entries.each do |entry|
      @access_grants_by_year[entry["year"]] = entry["cnt"]
    end

    @access_grants_by_year
  end

  def access_tokens_by_year
    return @access_tokens_by_year if @access_tokens_by_year

    @access_tokens_by_year = {}
    entries = select_all("SELECT YEAR(oauth_access_tokens.created_at) AS year, IFNULL(revoked_at,now()+'1 year') < now() AS expired, COUNT(*) AS cnt FROM oauth_access_tokens GROUP BY year, expired ORDER BY year, expired")
    entries.each do |entry|
      @access_tokens_by_year[entry["year"]] ||= {}
      @access_tokens_by_year[entry["year"]][entry["expired"]] ||= 0
      @access_tokens_by_year[entry["year"]][entry["expired"]] += entry["cnt"]
    end

    @access_tokens_by_year
  end

end
