class AllowLongTextInContents < ActiveRecord::Migration
  TABLES = %w(news diaries posts trackers comments)

  def up
    TABLES.each do |tbl|
      execute "ALTER TABLE #{tbl} MODIFY COLUMN body MEDIUMTEXT"
    end
  end

  def down
    TABLES.each do |tbl|
      execute "ALTER TABLE #{tbl} MODIFY COLUMN body TEXT"
    end
  end
end
