class CreateReadings < ActiveRecord::Migration
  def self.up
    create_table :readings do |t|
      t.references :user
      t.references :node
      t.datetime :updated_at
    end
    add_index :readings, [:node_id, :user_id], :unique => true
  end

  def self.down
    drop_table :readings
  end
end
