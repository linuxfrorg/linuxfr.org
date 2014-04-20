# encoding: utf-8
class AddGravatarHashToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gravatar_hash, :string, limit: 32
    User.reset_column_information
    Account.find_each {|a| a.email_will_change! ; a.update_gravatar_hash }
  end

  def self.down
    remove_column :users, :gravatar_hash
  end
end
