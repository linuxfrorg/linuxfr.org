class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
