# encoding: utf-8
class CreatePolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.string :state, null: false, limit: 10, default: 'draft'
      t.string :title, null: false, limit: 128
      t.string :cached_slug,           limit: 128
      t.timestamps
    end
    add_index :polls, :state
    add_index :polls, :cached_slug
  end

  def self.down
    drop_table :polls
  end
end
