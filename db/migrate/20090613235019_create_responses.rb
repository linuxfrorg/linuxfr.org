# encoding: utf-8
class CreateResponses < ActiveRecord::Migration
  def self.up
    create_table :responses do |t|
      t.string :title, :null => false
      t.text :content
    end
  end

  def self.down
    drop_table :responses
  end
end
