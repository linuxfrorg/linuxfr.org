class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.references :content, :polymorphic => true
      t.integer :score, :default => 0
      t.references :user
      t.boolean :public, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
