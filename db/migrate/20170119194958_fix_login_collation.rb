class FixLoginCollation < ActiveRecord::Migration
  def up
    execute "ALTER TABLE accounts MODIFY COLUMN login VARCHAR(40) COLLATE utf8mb4_bin NOT NULL;"
  end

  def down
    execute "ALTER TABLE accounts MODIFY COLUMN login VARCHAR(40) COLLATE utf8_unicode_ci NOT NULL;"
  end
end
