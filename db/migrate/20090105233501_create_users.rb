class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :login, :limit => 40,  :null => false
      t.string   :name,  :limit => 100
      t.string   :homesite
      t.string   :jabber_id
      t.string   :role,  :null => false, :default => 'moule'
      t.string   :state, :null => false, :default => 'passive'
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
