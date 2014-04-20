# encoding: utf-8
class RemovePasswordSaltColumn < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :password_salt
  end

  def self.down
    add_column :accounts, :password_salt, :string, default: "", null: false
  end
end
