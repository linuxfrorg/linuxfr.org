# encoding: utf-8
class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :state, null: false, limit: 10, default: 'published'
      t.string :title, null: false, limit: 32
      t.string :cached_slug,           limit: 32

      t.timestamps
    end
    add_index :sections, :cached_slug
    add_index :sections, [:state, :title]
  end

  def self.down
    drop_table :sections
  end
end
