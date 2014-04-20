# encoding: utf-8
class CreateWikiPages < ActiveRecord::Migration
  def self.up
    create_table :wiki_pages do |t|
      t.string :title, null: false, limit: 64
      t.string :cached_slug,           limit: 64
      t.text :body
      t.timestamps
    end
    add_index :wiki_pages, :cached_slug
  end

  def self.down
    drop_table :wiki_pages
  end
end
