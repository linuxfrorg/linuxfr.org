# encoding: utf-8
class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.string :title,       limit: 160, null: false
      t.string :cached_slug, limit: 165
      t.integer :owner_id
      t.string :link, null: false
      t.string :lang, null: false, limit: 2
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :bookmarks, :owner_id
    add_index :bookmarks, :cached_slug
  end

  def self.down
    drop_table :bookmarks
  end
end
