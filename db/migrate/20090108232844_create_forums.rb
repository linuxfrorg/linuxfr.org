class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :state, :null => false, :default => 'active'
      t.string :title
      t.string :cached_slug
      t.integer :position
      t.timestamps
    end
    add_index :forums, :cached_slug
  end

  def self.down
    drop_table :forums
  end
end
