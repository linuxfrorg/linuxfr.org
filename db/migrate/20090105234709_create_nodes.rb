class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.references :content, :polymorphic => true
      t.integer :score, :default => 0
      t.integer :interest, :default => 0
      t.references :user
      t.boolean :public, :default => true
      t.boolean :cc_licensed, :default => false
      t.integer :comments_count, :default => 0
      t.datetime :last_commented_at
      t.timestamps
    end
    add_index :nodes, [:content_type, :content_id], :unique => true
    add_index :nodes, :user_id
  end

  def self.down
    drop_table :nodes
  end
end
