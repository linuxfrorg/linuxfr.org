class EnlargeSecondPartOfNewsVersion < ActiveRecord::Migration
  def up
    execute "ALTER TABLE news_versions MODIFY COLUMN body MEDIUMTEXT"
    execute "ALTER TABLE news_versions MODIFY COLUMN second_part MEDIUMTEXT"
  end

  def down
    execute "ALTER TABLE news_versions MODIFY COLUMN second_part TEXT"
    execute "ALTER TABLE news_versions MODIFY COLUMN body TEXT"
  end
end
