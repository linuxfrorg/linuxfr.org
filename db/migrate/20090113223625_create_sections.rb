class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :state
      t.string :title, :null => false, :default => 'published'
      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
