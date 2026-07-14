class AlterUrlOnLinksAndLinkOnBookmarks < ActiveRecord::Migration[4.2]
  def up
    execute "ALTER TABLE links MODIFY url varchar(2047) NULL;"
    execute "ALTER TABLE bookmarks MODIFY link varchar(2047) NULL;"
  end

  def down
    execute "ALTER TABLE links MODIFY url varchar(255) NULL;"
    execute "ALTER TABLE bookmarks MODIFY link varchar(255) NULL;"
  end

  def db_name
    Rails.configuration.database_configuration[Rails.env]['database']
  end
end
