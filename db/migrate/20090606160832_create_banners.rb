# encoding: utf-8
class CreateBanners < ActiveRecord::Migration
  def self.up
    create_table :banners do |t|
      t.string :title
      t.text :content
    end
  end

  def self.down
    drop_table :banners
  end
end
