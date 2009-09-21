class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.string :cache_slug

      # Image
      t.string   :image_file_name
      t.string   :image_content_type
      t.integer  :image_file_size
      t.datetime :image_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
