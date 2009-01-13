class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :node
      t.references :user
      t.string :state, :null => false, :default => 'published'
      t.string :title
      t.text :body
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
