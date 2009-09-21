class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :state, :null => false, :default => 'active'
      t.string :title
      t.string :cache_slug
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :forums
  end
end
