class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.string :cached_slug

      # Image
      t.string   :image_file_name
      t.string   :image_content_type
      t.integer  :image_file_size
      t.datetime :image_updated_at

      t.timestamps
    end
    add_index :sections, :cached_slug
  end

  def self.down
    drop_table :sections
  end
end
