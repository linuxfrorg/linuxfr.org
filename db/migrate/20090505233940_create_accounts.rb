class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.references :user
      t.string   :login, :limit => 40,  :null => false
      t.string   :email, :limit => 100, :null => false
      t.string   :state,                :null => false, :default => 'passive'
      t.string   :crypted_password,     :null => false
      t.string   :password_salt,        :null => false
      t.string   :persistence_token,    :null => false
      t.string   :single_access_token,  :null => false
      t.string   :perishable_token,     :null => false
      t.integer  :login_count,          :null => false, :default => 0
      t.integer  :failed_login_count,   :null => false, :default => 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string   :current_login_ip
      t.string   :last_login_ip
      t.integer  :karma,                :null => false, :default => 20
      t.integer  :nb_votes,             :null => false, :default => 0
      t.string   :stylesheet
      t.string   :old_password, :limit => 20
      t.timestamps
    end

    execute "ALTER TABLE `accounts` MODIFY COLUMN `crypted_password` VARCHAR(255) BINARY CHARACTER SET latin1 COLLATE latin1_bin NOT NULL"
    execute "ALTER TABLE `accounts` MODIFY COLUMN `password_salt` VARCHAR(255) BINARY CHARACTER SET latin1 COLLATE latin1_bin NOT NULL"
    execute "ALTER TABLE `accounts` MODIFY COLUMN `persistence_token` VARCHAR(255) BINARY CHARACTER SET latin1 COLLATE latin1_bin NOT NULL"
    execute "ALTER TABLE `accounts` MODIFY COLUMN `single_access_token` VARCHAR(255) BINARY CHARACTER SET latin1 COLLATE latin1_bin NOT NULL"
    execute "ALTER TABLE `accounts` MODIFY COLUMN `perishable_token` VARCHAR(255) BINARY CHARACTER SET latin1 COLLATE latin1_bin NOT NULL"

    add_index :accounts, :user_id
    add_index :accounts, :login
    add_index :accounts, :email
    add_index :accounts, :persistence_token
    add_index :accounts, :single_access_token
    add_index :accounts, :perishable_token
  end

  def self.down
    drop_table :accounts
  end
end
