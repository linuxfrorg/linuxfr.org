class CachedSlugNotNull < ActiveRecord::Migration[4.2]
  def up
    execute "ALTER TABLE bookmarks MODIFY cached_slug varchar(165) NOT NULL;"
    execute "ALTER TABLE diaries MODIFY cached_slug varchar(165) NOT NULL;"
    execute "ALTER TABLE forums MODIFY cached_slug varchar(32) NOT NULL;"
    execute "ALTER TABLE news MODIFY cached_slug varchar(165) NOT NULL;"
    execute "ALTER TABLE polls MODIFY cached_slug varchar(128) NOT NULL;"
    execute "ALTER TABLE posts MODIFY cached_slug varchar(165) NOT NULL;"
    execute "ALTER TABLE sections MODIFY cached_slug varchar(32) NOT NULL;"
    execute "ALTER TABLE trackers MODIFY cached_slug varchar(105) NOT NULL;"
    execute "ALTER TABLE users MODIFY cached_slug varchar(32) NOT NULL;"
    execute "ALTER TABLE wiki_pages MODIFY cached_slug varchar(105) NOT NULL;"
  end

  def down
    execute "ALTER TABLE bookmarks MODIFY cached_slug varchar(165) NULL;"
    execute "ALTER TABLE diaries MODIFY cached_slug varchar(165) NULL;"
    execute "ALTER TABLE forums MODIFY cached_slug varchar(32) NULL;"
    execute "ALTER TABLE news MODIFY cached_slug varchar(165) NULL;"
    execute "ALTER TABLE polls MODIFY cached_slug varchar(128) NULL;"
    execute "ALTER TABLE posts MODIFY cached_slug varchar(165) NULL;"
    execute "ALTER TABLE sections MODIFY cached_slug varchar(32) NULL;"
    execute "ALTER TABLE trackers MODIFY cached_slug varchar(105) NULL;"
    execute "ALTER TABLE users MODIFY cached_slug varchar(32) NULL;"
    execute "ALTER TABLE wiki_pages MODIFY cached_slug varchar(105) NULL;"
  end

  def db_name
    Rails.configuration.database_configuration[Rails.env]['database']
  end
end
