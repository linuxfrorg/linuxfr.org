class CreateTrackers < ActiveRecord::Migration
  def self.up
    create_table :trackers do |t|
      t.string :state, :null => false, :default => 'opened'
      t.string :title
      t.string :cached_slug
      t.text :body
      t.text :wiki_body
      t.references :category
      t.references :assigned_to_user
      t.timestamps
    end
    add_index :trackers, :state
    add_index :trackers, :cached_slug
    add_index :trackers, :category_id
    add_index :trackers, :assigned_to_user_id
  end

  def self.down
    drop_table :trackers
  end
end
