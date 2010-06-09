class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.string :cached_slug
      t.text :body
      t.text :wiki_body
      t.references :forum
      t.integer :owner_id
      t.timestamps
    end
    add_index :posts, [:state, :owner_id]
    add_index :posts, :cached_slug
    add_index :posts, :forum_id
  end

  def self.down
    drop_table :posts
  end
end
