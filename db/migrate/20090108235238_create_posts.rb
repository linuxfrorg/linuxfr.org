class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.text :body
      t.references :forum
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
