class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.string :state, :null => false, :default => 'draft'
      t.string :title
      t.string :cached_slug
      t.text :body
      t.text :second_part
      t.references :moderator
      t.references :section
      t.string :author_name,  :null => false
      t.string :author_email, :null => false
      t.timestamps
    end
    add_index :news, [:state, :section_id]
    add_index :news, :cached_slug
  end

  def self.down
    drop_table :news
  end
end
