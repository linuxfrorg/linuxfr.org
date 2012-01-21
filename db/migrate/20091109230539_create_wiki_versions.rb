# encoding: utf-8
class CreateWikiVersions < ActiveRecord::Migration
  def self.up
    create_table :wiki_versions do |t|
      t.references :wiki_page
      t.references :user
      t.integer :version
      t.string :message
      t.text :body
      t.datetime :created_at
    end
    add_index :wiki_versions, [:wiki_page_id, :version]
  end

  def self.down
    drop_table :wiki_versions
  end
end
