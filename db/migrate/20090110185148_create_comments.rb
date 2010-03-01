class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :node
      t.references :user
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.text :body
      t.text :wiki_body
      t.integer :score, :default => 0
      t.boolean :answered_to_self, :default => false
      t.string :materialized_path, :limit => 1022
      t.timestamps
    end
    add_index :comments, :node_id
    add_index :comments, [:user_id, :answered_to_self]
    add_index :comments, [:state, :created_at]
    add_index :comments, [:state, :materialized_path, :created_at]
  end

  def self.down
    drop_table :comments
  end
end
