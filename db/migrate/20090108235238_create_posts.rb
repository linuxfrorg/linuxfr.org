class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.string :cached_slug
      t.text :body
      t.references :forum
      t.timestamps
    end
    add_index :posts, :state
    add_index :posts, :cached_slug
  end

  def self.down
    drop_table :posts
  end
end
