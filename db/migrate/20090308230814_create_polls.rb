class CreatePolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.string :state, :null => false, :default => 'draft'
      t.string :title
      t.string :cache_slug
      t.timestamps
    end
  end

  def self.down
    drop_table :polls
  end
end
