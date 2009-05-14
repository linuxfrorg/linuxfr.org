class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :name,  :limit => 100
      t.string   :homesite
      t.string   :jabber_id
      t.string   :role,  :null => false, :default => 'moule'
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
