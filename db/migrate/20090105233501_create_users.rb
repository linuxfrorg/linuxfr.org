class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :login, :limit => 40,  :null => false
      t.string   :email, :limit => 100, :null => false
      t.string   :name,  :limit => 100
      t.string   :homesite
      t.string   :jabber_id
      t.string   :role,  :null => false, :default => 'moule'
      t.string   :state, :null => false, :default => 'passive'
      t.string   :salt,  :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :crypted_password, :limit => 40
      t.string   :activation_code,  :limit => 40
      t.datetime :activated_at
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
