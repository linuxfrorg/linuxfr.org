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
      t.string :author_name,  :null => false, :default => 'anonymous'
      t.string :author_email, :null => false, :default => 'anonymous@dlfp.org'
      t.timestamps
    end
  end

  def self.down
    drop_table :news
  end
end
