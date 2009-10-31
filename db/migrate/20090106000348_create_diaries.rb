class CreateDiaries < ActiveRecord::Migration
  def self.up
    create_table :diaries do |t|
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.string :cached_slug
      t.integer :owner_id
      t.text :body
      t.timestamps
    end
    add_index :diaries, [:state, :owner_id]
    add_index :diaries, :cached_slug
  end

  def self.down
    drop_table :diaries
  end
end
