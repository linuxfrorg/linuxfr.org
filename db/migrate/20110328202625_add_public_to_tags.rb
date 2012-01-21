# encoding: utf-8
class AddPublicToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :public, :boolean, :default => true, :null => false
    remove_index :tags, :taggings_count
    add_index :tags, [:public, :taggings_count]
    remove_index :tags, :name
    add_index :tags, :name, :unique => true
    add_index :taggings, [:created_at, :tag_id]
  end

  def self.down
    remove_index :taggings, [:created_at, :tag_id]
    remove_column :tags, :public
    remove_index :tags, :name
    add_index :tags, :name
    remove_index :tags, [:public, :taggings_count]
    add_index :tags, :taggings_count
  end
end
