class CreateDictionaries < ActiveRecord::Migration
  def self.up
    create_table :dictionaries do |t|
      t.string :key,   :limit => 16, :null => false
      t.string :value, :limit => 1024
    end
    add_index :dictionaries, [:key], :unique => true
  end

  def self.down
    drop_table :dictionaries
  end
end
