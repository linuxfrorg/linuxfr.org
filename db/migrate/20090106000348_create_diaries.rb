class CreateDiaries < ActiveRecord::Migration
  def self.up
    create_table :diaries do |t|
      t.string :title
      t.string :cached_slug
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
