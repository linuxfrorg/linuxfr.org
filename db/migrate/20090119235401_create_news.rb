class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.string :state, :null => false, :limit => 10, :default => 'draft'
      t.string :title, :null => false, :limit => 64
      t.string :cached_slug,           :limit => 64
      t.references :moderator
      t.references :section
      t.string :author_name,  :null => false, :limit => 32
      t.string :author_email, :null => false, :limit => 64
      t.text :body
      t.text :second_part
      t.timestamps
    end

    # Patrick_g writes long enough news that TEXT can't store them completely!
    execute "ALTER TABLE news MODIFY COLUMN second_part MEDIUMTEXT"

    add_index :news, :state
    add_index :news, :section_id
    add_index :news, :cached_slug
  end

  def self.down
    drop_table :news
  end
end
