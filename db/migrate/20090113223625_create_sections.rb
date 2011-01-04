class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :state, :null => false, :limit => 10, :default => 'published'
      t.string :title, :null => false, :limit => 32
      t.string :cached_slug,           :limit => 32

      # Image
      t.string   :image_file_name
      t.string   :image_content_type
      t.integer  :image_file_size
      t.datetime :image_updated_at

      t.timestamps
    end
    add_index :sections, :cached_slug
    add_index :sections, [:state, :title]
  end

  def self.down
    drop_table :sections
  end
end
