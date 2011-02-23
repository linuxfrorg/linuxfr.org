class AddPreferencesToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :preferences, :integer, :default => 0, :null => false
    remove_index :nodes, ["content_type", "public"]
    add_index :nodes, ["content_type", "public", "interest"]
  end

  def self.down
    remove_index :nodes, ["content_type", "public"]
    add_index :nodes, ["content_type", "public"]
    remove_column :accounts, :preferences
  end
end
