class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.references :forum
      t.string :title,       :limit => 64, :null => false
      t.string :cached_slug, :limit => 64
      t.text :body
      t.text :wiki_body
      t.text :truncated_body
      t.timestamps
    end
    add_index :posts, :cached_slug
    add_index :posts, :forum_id
  end

  def self.down
    drop_table :posts
  end
end
