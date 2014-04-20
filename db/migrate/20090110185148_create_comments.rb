# encoding: utf-8
class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :node
      t.references :user
      t.string :state, null: false, limit: 10, default: 'published'
      t.string :title, null: false, limit: 32
      t.integer :score,            null: false, default: 0
      t.boolean :answered_to_self, null: false, default: false
      t.string :materialized_path, limit: 1022
      t.text :body
      t.text :wiki_body
      t.timestamps
    end
    add_index :comments, :node_id
    add_index :comments, [:user_id, :answered_to_self]
    add_index :comments, [:user_id, :state, :created_at]
    add_index :comments, [:state, :created_at]
    add_index :comments, [:state, :materialized_path], length: { materialized_path: 120 }
  end

  def self.down
    drop_table :comments
  end
end
