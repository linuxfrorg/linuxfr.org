class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :content_type
      t.integer :content_id
      t.integer :score
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
