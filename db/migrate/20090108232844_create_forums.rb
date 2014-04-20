# encoding: utf-8
class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :state, null: false, limit: 10, default: 'active'
      t.string :title, null: false, limit: 32
      t.string :cached_slug,           limit: 32
      t.integer :position
      t.timestamps
    end
    add_index :forums, :cached_slug
  end

  def self.down
    drop_table :forums
  end
end
