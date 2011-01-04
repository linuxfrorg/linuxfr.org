class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.references :content, :polymorphic => true
      t.references :user
      t.boolean :public,         :null => false, :default => true
      t.boolean :cc_licensed,    :null => false, :default => false
      t.integer :score,          :null => false, :default => 0
      t.integer :interest,       :null => false, :default => 0
      t.integer :comments_count, :null => false, :default => 0
      t.datetime :last_commented_at
      t.timestamps
    end
    add_index :nodes, [:content_id, :content_type], :unique => true
    add_index :nodes, [:content_type, :public]
    add_index :nodes, [:public, :created_at]
    add_index :nodes, [:public, :score]
    add_index :nodes, [:public, :interest]
    add_index :nodes, [:public, :last_commented_at]
    add_index :nodes, :user_id
  end

  def self.down
    drop_table :nodes
  end
end
