class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.references :tag
      t.references :node
      t.references :user
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :taggings
  end
end
