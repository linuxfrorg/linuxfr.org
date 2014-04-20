# encoding: utf-8
class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.references :user
      t.string   :login, limit: 40,  null: false
      t.string   :role,  limit: 10,  null: false, default: 'moule'
      t.integer  :karma,                null: false, default: 20
      t.integer  :nb_votes,             null: false, default: 0
      t.string   :stylesheet
      t.string   :old_password, limit: 20

      ### Devise ###

      # Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      # Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      # Recoverable
      t.string   :reset_password_token

      # Rememberable
      t.datetime :remember_created_at
      t.string :remember_token

      # Trackable
      t.integer  :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      # Encrytable
      t.string :password_salt

      t.timestamps
    end

    add_index :accounts, :user_id
    add_index :accounts, :login
    add_index :accounts, :role
    add_index :accounts, :email,                unique: true
    add_index :accounts, :confirmation_token,   unique: true
    add_index :accounts, :reset_password_token, unique: true

    execute "ALTER TABLE accounts CHANGE login login varchar(40) COLLATE utf8_bin NOT NULL;"
  end

  def self.down
    drop_table :accounts
  end
end
