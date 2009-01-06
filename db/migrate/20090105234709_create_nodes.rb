class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.integer :score
      t.string :content_type
      t.integer :content_id
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
