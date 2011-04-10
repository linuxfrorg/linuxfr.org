class Statistics::Users

  def select_all(sql)
    ActiveRecord::Base.connection.select_all(sql)
  end

  def count(sql, field="cnt")
    rows = select_all(sql)
    rows.any? ? rows.first[field] : 0
  end

  def pctrecent(value)
    "%.0f" % (100.0 * value / nb_recently_used_accounts)
  end

  def nb_users
    count "SELECT COUNT(*) AS cnt FROM users"
  end

  def nb_accounts
    count "SELECT COUNT(*) AS cnt FROM accounts"
  end

  def nb_recently_used_accounts
    count "SELECT COUNT(*) AS cnt FROM users WHERE updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY)"
  end

  def nb_waiting_accounts
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE confirmed_at IS NULL"
  end

  def nb_closed_accounts
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE role='inactive'"
  end

  def no_visit
    rows = select_all "SELECT IFNULL(ROUND(AVG(TO_DAYS(CURRENT_TIMESTAMP)-TO_DAYS(updated_at)),1),0) AS avg, IFNULL(ROUND(SQRT(VAR_POP(TO_DAYS(CURRENT_TIMESTAMP)-TO_DAYS(updated_at))),1),0) AS stddev FROM users WHERE updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY)"
    novisit = rows.first
  end

  def nb_authors
    select_all "SELECT COUNT(DISTINCT(user_id)) AS cnt, content_type FROM nodes JOIN users ON nodes.user_id = users.id WHERE users.updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY) GROUP BY content_type"
  end

  def filled(field)
    count "SELECT COUNT(*) AS cnt FROM users WHERE #{field} IS NOT NULL AND updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY)"
  end

  def preferences(field)
    count "SELECT COUNT(*) AS cnt FROM accounts JOIN users ON users.id = accounts.user_id WHERE #{Account.bitfield_sql field => true} AND users.updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY)"
  end

  def accounts_with_no_contents
    no_contents_sql = Account.bitfield_sql(:news_on_home => false, :diaries_on_home => false, :posts_on_home => false, :polls_on_home => false, :wiki_pages_on_home => false, :trackers_on_home => false)
    count "SELECT COUNT(*) AS cnt FROM accounts JOIN users ON users.id = accounts.user_id WHERE #{no_contents_sql} AND users.updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY)"
  end

  def on_home(content_type)
    cnt  = preferences("#{content_type.tableize}_on_home".to_sym)
    cnt += accounts_with_no_contents if HomeController::DEFAULT_TYPES.include?(content_type)
    cnt
  end

  def by_karma
    select_all "SELECT SIGN(karma) AS sign, FLOOR(LOG10(ABS(karma)+1E-99)) as k, COUNT(*) AS cnt FROM accounts JOIN users ON users.id = accounts.user_id WHERE karma IS NOT NULL AND users.updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY) GROUP BY sign,k ORDER BY sign ASC, sign*k ASC"
  end

  def by_style
    select_all "SELECT TRIM(stylesheet) AS stylesheet, COUNT(*) AS cnt FROM accounts JOIN users ON users.id = accounts.user_id WHERE users.updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY) GROUP BY stylesheet HAVING cnt > 2 ORDER BY cnt DESC"
  end

  def by_year
    select_all "SELECT YEAR(accounts.created_at) AS year, COUNT(*) AS cnt FROM accounts JOIN users ON users.id = accounts.user_id WHERE users.updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY) GROUP BY year ORDER BY year ASC"
  end

  def by_state
    select_all "SELECT user_id DIV 2500 AS slot, COUNT(*) AS cnt, (role='inactive') AS inactive, (updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY)) AS recent FROM accounts GROUP BY slot,inactive,recent ORDER BY slot ASC, inactive ASC, recent ASC"
  end
end
