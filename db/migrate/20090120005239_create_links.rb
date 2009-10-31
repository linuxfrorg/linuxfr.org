class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.references :news
      t.string :title
      t.string :url
      t.string :lang
      t.integer :nb_clicks, :default => 0
      t.timestamps
    end
    add_index :links, :news_id
  end

  def self.down
    drop_table :links
  end
end
