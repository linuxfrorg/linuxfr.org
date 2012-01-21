# encoding: utf-8
class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.references :tag
      t.references :node
      t.references :user
      t.datetime :created_at
    end
    add_index :taggings, :tag_id
    add_index :taggings, :node_id
    add_index :taggings, :user_id
  end

  def self.down
    drop_table :taggings
  end
end
