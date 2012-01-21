# encoding: utf-8
class CreateAccessGrants < ActiveRecord::Migration
  def change
    create_table :access_grants do |t|
      t.references :account
      t.references :client_application
      t.string :code
      t.string :access_token
      t.string :refresh_token
      t.datetime :access_token_expires_at
      t.timestamps
    end
    add_index :access_grants, [:account_id, :code]
    add_index :access_grants, :client_application_id
    add_index :access_grants, :access_token
  end
end
