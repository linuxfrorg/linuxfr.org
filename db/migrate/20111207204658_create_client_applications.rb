class CreateClientApplications < ActiveRecord::Migration
  def change
    create_table :client_applications do |t|
      t.references :account
      t.string :name
      t.string :app_id,     :limit => 32
      t.string :app_secret, :limit => 32
      t.timestamps
    end
    add_index :client_applications, :app_id
  end
end
