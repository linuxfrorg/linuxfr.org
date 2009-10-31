class CreatePolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.string :state, :null => false, :default => 'draft'
      t.string :title
      t.string :cached_slug
      t.timestamps
    end
    add_index :polls, :state
    add_index :polls, :cached_slug
  end

  def self.down
    drop_table :polls
  end
end
