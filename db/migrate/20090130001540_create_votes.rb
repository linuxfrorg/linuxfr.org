class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.references :user
      t.references :node
      t.boolean :vote
      t.datetime :created_at
    end
    add_index :votes, [:node_id, :user_id], :unique => true
    add_index :votes, [:created_at, :vote, :node_id]
  end

  def self.down
    drop_table :votes
  end
end
