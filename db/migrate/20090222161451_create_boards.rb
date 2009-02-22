class CreateBoards < ActiveRecord::Migration
  def self.up
    create_table :boards do |t|
      t.references :user
      t.references :object, :polymorphic => true
      t.text :message
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :boards
  end
end
