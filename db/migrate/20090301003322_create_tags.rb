class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name, :null => false, :limit => 64
      t.integer :taggings_count, :default => 0, :null => false
    end
    add_index :tags, :name
    add_index :tags, :taggings_count
  end

  def self.down
    drop_table :tags
  end
end
