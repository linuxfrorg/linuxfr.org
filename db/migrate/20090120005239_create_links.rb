class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.references :news, :null => false
      t.string :title
      t.string :url
      t.string :lang
      t.references :locked_by
      t.timestamps
    end
    add_index :links, :news_id
  end

  def self.down
    drop_table :links
  end
end
