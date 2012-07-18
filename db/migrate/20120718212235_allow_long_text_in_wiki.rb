class AllowLongTextInWiki < ActiveRecord::Migration
  def up
    execute "ALTER TABLE wiki_pages MODIFY COLUMN body MEDIUMTEXT"
    execute "ALTER TABLE wiki_versions MODIFY COLUMN body MEDIUMTEXT"
  end

  def down
    execute "ALTER TABLE wiki_pages MODIFY COLUMN body TEXT"
    execute "ALTER TABLE wiki_versions MODIFY COLUMN body TEXT"
  end
end
