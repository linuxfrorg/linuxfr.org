class AlterCachedSlugs < ActiveRecord::Migration
  TABLES = {
    news: 165,
    diaries: 165,
    forums: 32,
    polls: 128,
    posts: 165,
    sections: 32,
    trackers: 105,
    users: 32,
    wiki_pages: 105
  }

  def up
    TABLES.each do |tbl, len|
      execute "ALTER TABLE #{tbl} MODIFY cached_slug varchar(#{len}) COLLATE utf8_bin DEFAULT NULL;"
    end
    execute "ALTER TABLE friendly_id_slugs MODIFY slug varchar(255) COLLATE utf8_bin DEFAULT NULL;"
  end

  def down
    execute "ALTER TABLE friendly_id_slugs MODIFY slug varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL;"
    TABLES.each do |tbl, len|
      execute "ALTER TABLE #{tbl} MODIFY cached_slug varchar(#{len}) COLLATE utf8_unicode_ci DEFAULT NULL;"
    end
  end
end
