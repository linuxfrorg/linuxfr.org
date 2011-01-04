class CreateDiaries < ActiveRecord::Migration
  def self.up
    create_table :diaries do |t|
      t.string :title,       :limit => 64, :null => false
      t.string :cached_slug, :limit => 64
      t.integer :owner_id
      t.text :body
      t.text :wiki_body
      t.text :truncated_body
      t.timestamps
    end
    add_index :diaries, :owner_id
    add_index :diaries, :cached_slug
  end

  def self.down
    drop_table :diaries
  end
end
