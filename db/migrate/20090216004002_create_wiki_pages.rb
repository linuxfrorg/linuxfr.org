class CreateWikiPages < ActiveRecord::Migration
  def self.up
    create_table :wiki_pages do |t|
      t.string :title
      t.string :cached_slug
      t.text :body
      t.timestamps
    end
    add_index :wiki_pages, :cached_slug
  end

  def self.down
    drop_table :wiki_pages
  end
end
