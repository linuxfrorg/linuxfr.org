# encoding: utf-8
class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.references :news, null: false
      t.string :title, null: false, limit: 100
      t.string :url,   null: false
      t.string :lang,  null: false, limit: 2
      t.references :locked_by
      t.timestamps
    end
    add_index :links, :news_id
  end

  def self.down
    drop_table :links
  end
end
