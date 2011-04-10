class Statistics::Users

  def select_all(sql)
    ActiveRecord::Base.connection.select_all(sql)
  end

  def count(sql, field="cnt")
    rows = select_all(sql)
    rows.any? ? rows.first[field] : 0
  end

  def pctrecent(value)
    "%.0f" % (100.0*value/nbrecentlyusedaccounts)
  end

  def nbusers
    count "SELECT COUNT(*) AS cnt FROM users"
  end

  def nbaccounts
    count "SELECT COUNT(*) AS cnt FROM accounts"
  end

  def nbrecentlyusedaccounts
    count "SELECT COUNT(*) AS cnt FROM users WHERE updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY);"
  end

  def nbwaitingaccounts
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE confirmed_at IS NULL;"
  end

  def nbclosedaccounts
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE role='inactive';"
  end

  def novisit
    rows = select_all "SELECT IFNULL(ROUND(AVG(TO_DAYS(CURRENT_TIMESTAMP)-TO_DAYS(updated_at)),1),0) AS avg, IFNULL(ROUND(SQRT(VAR_POP(TO_DAYS(CURRENT_TIMESTAMP)-TO_DAYS(updated_at))),1),0) AS stddev FROM users WHERE updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY);"
    novisit = rows.first
  end

  def nbauthors
    select_all "SELECT DISTINCT(user_id) AS cnt,content_type FROM nodes,users WHERE nodes.user_id=users.id AND users.updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY) GROUP BY content_type;"
  end

  def filledsite
    count "SELECT COUNT(*) AS cnt FROM users WHERE homesite IS NOT NULL AND updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY);"
  end

  def filledjabber
    count "SELECT COUNT(*) AS cnt FROM users WHERE jabber_id IS NOT NULL AND updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY);"
  end

  def filledsignature
    count "SELECT COUNT(*) AS cnt FROM users WHERE signature IS NOT NULL AND updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY);"
  end

  def filledavatar
    count "SELECT COUNT(*) AS cnt FROM users WHERE avatar IS NOT NULL AND updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY);"
  end

  def preferences(value)
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE (preferences&"+value+")="+value+" AND preferences<>0 AND updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY);"
  end

  def bykarma
    select_all "SELECT SIGN(karma) AS sign, FLOOR(LOG10(ABS(karma)+1E-99)) as k, COUNT(*) AS cnt FROM accounts WHERE karma IS NOT NULl AND updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY) GROUP BY sign,k ORDER BY sign ASC, sign*k ASC;"
  end

  def bystyle
    select_all "SELECT TRIM(stylesheet),COUNT(*) AS cnt FROM accounts WHERE updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY) GROUP BY stylesheet HAVING cnt > 2 ORDER BY cnt DESC;"
  end

  def byyear
    select_all "SELECT YEAR(created_at) AS year,COUNT(*) AS cnt FROM accounts WHERE updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY) GROUP BY year ORDER BY year ASC;"
  end

  def bystate
    select_all "SELECT user_id DIV 2500 AS slot,COUNT(*) AS cnt,(role='inactive') AS inactive, (updated_at > DATE_SUB(CURDATE(),INTERVAL 90 DAY)) AS recent FROM accounts GROUP BY slot,inactive,recent ORDER BY slot ASC,inactive ASC,recent ASC;"
  end

end
