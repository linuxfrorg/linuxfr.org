class CreateTrackers < ActiveRecord::Migration
  def self.up
    create_table :trackers do |t|
      t.string :state, :null => false, :default => 'open'
      t.string :title
      t.string :cached_slug
      t.text :body
      t.references :category
      t.references :assigned_to_user
      t.timestamps
    end
  end

  def self.down
    drop_table :trackers
  end
end
