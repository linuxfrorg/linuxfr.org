class CreateBoards < ActiveRecord::Migration
  def self.up
    create_table :boards do |t|
      t.string :user_agent
      t.references :user
      t.references :object, :polymorphic => true
      t.text :message
      t.datetime :created_at
    end
    add_index :boards, [:object_type, :object_id]
  end

  def self.down
    drop_table :boards
  end
end
