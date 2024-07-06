# encoding: utf-8
class Statistics::Users < Statistics::Statistics

  def pctrecent(value)
    "%.0f%%" % (100.0 * value / nb_recently_seen_accounts)
  end

  def nb_users
    count "SELECT COUNT(*) AS cnt FROM users"
  end

  def nb_accounts
    count "SELECT COUNT(*) AS cnt FROM accounts"
  end

  def nb_recently_seen_accounts
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive'"
  end

  def nb_waiting_accounts
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE confirmed_at IS NULL"
  end

  def nb_closed_accounts
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE role='inactive'"
  end

  def no_visit
    rows = select_all "SELECT IFNULL(ROUND(AVG(TO_DAYS(CURRENT_TIMESTAMP) - TO_DAYS(last_seen_on)), 1), 0) AS avg, IFNULL(ROUND(SQRT(VAR_POP(TO_DAYS(CURRENT_TIMESTAMP) - TO_DAYS(last_seen_on))), 1), 0) AS stddev FROM accounts WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive'"
    rows.first
  end

  def nb_content_authors(days=0, content_type='')
    node_age=''
    node_age="AND nodes.created_at > DATE_SUB(CURDATE(),INTERVAL #{days} DAY)" if days>0
    node_type="AND content_type='#{content_type}'" if content_type!=''

    select_all "SELECT COUNT(DISTINCT(accounts.user_id)) AS cnt, content_type FROM nodes JOIN accounts ON nodes.user_id = accounts.user_id WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' #{node_age} #{node_type} GROUP BY content_type;"
  end

  def nb_comment_authors(days=0)
    comment_age=''
    comment_age="AND comments.created_at > DATE_SUB(CURDATE(),INTERVAL #{days} DAY)" if days>0

    select_all "SELECT COUNT(DISTINCT(accounts.user_id)) AS cnt FROM comments JOIN accounts ON comments.user_id = accounts.user_id WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' #{comment_age};"
  end

  def nb_tag_authors(days=0)
    tag_age=''
    tag_age="AND taggings.created_at > DATE_SUB(CURDATE(),INTERVAL #{days} DAY)" if days>0

    select_all "SELECT COUNT(DISTINCT(accounts.user_id)) AS cnt FROM taggings JOIN accounts ON taggings.user_id = accounts.user_id WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' #{tag_age};"
  end

  def nb_news_versions_authors(days=0)
    news_versions_age="AND news_versions.created_at > DATE_SUB(CURDATE(),INTERVAL #{days} DAY)" if days>0

    select_all "SELECT COUNT(DISTINCT(accounts.user_id)) AS cnt FROM news_versions JOIN accounts ON news_versions.user_id = accounts.user_id WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' #{news_versions_age};"
  end

  def filled(field)
    count "SELECT COUNT(*) AS cnt FROM users JOIN accounts ON users.id = accounts.user_id WHERE #{field} IS NOT NULL AND #{field} != '' AND last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY)"
  end

  def preferences(field)
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE #{Account.bitfield_sql field => true} AND last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive'"
  end

  def accounts_with_no_contents
    no_contents_sql = Account.bitfield_sql(news_on_home: false, diaries_on_home: false, posts_on_home: false, polls_on_home: false, wiki_pages_on_home: false, trackers_on_home: false)
    count "SELECT COUNT(*) AS cnt FROM accounts WHERE #{no_contents_sql} AND last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive'"
  end

  def on_home(content_type)
    cnt  = preferences("#{content_type.tableize}_on_home".to_sym)
    cnt += accounts_with_no_contents if HomeController::DEFAULT_TYPES.include?(content_type)
    cnt
  end

  KARMA_BASE=2
  def karma_base
    KARMA_BASE
  end

  def by_karma
    select_all "SELECT SIGN(karma) AS sign, FLOOR(LOG#{KARMA_BASE}(ABS(karma)+1E-99)) as k, COUNT(*) AS cnt FROM accounts WHERE karma IS NOT NULL AND last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' GROUP BY sign,k ORDER BY sign ASC, sign*k ASC"
  end

  def by_style
    select_all "SELECT TRIM(stylesheet) AS stylesheet, COUNT(*) AS cnt FROM accounts WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' GROUP BY stylesheet HAVING cnt > 2 ORDER BY cnt DESC"
  end

  def by_year
    select_all "SELECT YEAR(CONVERT_TZ(accounts.created_at, 'UTC', 'Europe/Paris')) AS year, COUNT(*) AS cnt FROM accounts WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' GROUP BY year ORDER BY year ASC"
  end

  ACCOUNT_SLOT=10000
  def slot_size
    ACCOUNT_SLOT
  end
  def by_state
    select_all "SELECT user_id DIV #{ACCOUNT_SLOT} AS slot, COUNT(*) AS cnt, (role='inactive') AS inactive, IFNULL(last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY),0) AS recent FROM accounts GROUP BY slot,inactive,recent ORDER BY slot ASC, inactive ASC, recent ASC"
  end

  def top_email_domains
    select_all "SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(email,'@', -1),'.',1) AS domain, COUNT(*) AS cnt FROM accounts WHERE last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' GROUP BY domain HAVING cnt > 3 ORDER BY cnt DESC LIMIT 10;"
  end

  def top_xmpp_domains
    select_all "SELECT SUBSTRING_INDEX(jabber_id,'@', -1) AS domain, COUNT(*) AS cnt FROM accounts LEFT JOIN users ON accounts.user_id=users.id WHERE jabber_id LIKE '%@%' AND last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' GROUP BY domain HAVING cnt > 3 ORDER BY cnt DESC LIMIT 10;"
  end

  def top_mastodon_domains
    # We assume Mastodon URLs will always start with "https://"
    select_all "SELECT SUBSTRING_INDEX(SUBSTRING(mastodon_url, 9),'/', 1) AS domain, COUNT(*) AS cnt FROM accounts LEFT JOIN users ON accounts.user_id=users.id WHERE mastodon_url LIKE 'https://%/%' AND last_seen_on > DATE_SUB(CURDATE(),INTERVAL 90 DAY) AND role<>'inactive' GROUP BY domain HAVING cnt > 3 ORDER BY cnt DESC LIMIT 10;"
  end
end
