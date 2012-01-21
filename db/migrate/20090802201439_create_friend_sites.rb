# encoding: utf-8
class CreateFriendSites < ActiveRecord::Migration
  def self.up
    create_table :friend_sites do |t|
      t.string :title
      t.string :url
      t.integer :position
    end
    add_index :friend_sites, :position
  end

  def self.down
    drop_table :friend_sites
  end
end
