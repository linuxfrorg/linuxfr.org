class FixCachedSlugCollation < ActiveRecord::Migration
  TABLES = [
    'news',
    'diaries',
    'posts',
  ]

  def up
    TABLES.each do |tbl|
      execute "ALTER TABLE #{tbl} MODIFY COLUMN cached_slug VARCHAR(165) COLLATE utf8mb4_bin;"
    end
  end

  def down
    TABLES.each do |tbl|
      execute "ALTER TABLE #{tbl} MODIFY COLUMN cached_slug VARCHAR(165) COLLATE utf8_unicode_ci;"
    end
  end
end
