class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.references :account
      t.string :description
      t.timestamps
    end
    add_index :logs, :account_id
  end
end
