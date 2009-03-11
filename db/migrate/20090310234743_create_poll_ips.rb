class CreatePollIps < ActiveRecord::Migration
  def self.up
    create_table :poll_ips do |t|
      t.integer :ip, :null => false
    end
    add_index :poll_ips, :ip, :unique => true
  end

  def self.down
    drop_table :poll_ips
  end
end
