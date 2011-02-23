class AddPreferencesToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :preferences, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :accounts, :preferences
  end
end
