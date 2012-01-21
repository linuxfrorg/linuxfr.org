# encoding: utf-8
class MigrateAvatarToCarrierwave < ActiveRecord::Migration
  def self.up
    change_table :users, :bulk => true do |t|
      t.string :avatar
      t.remove :avatar_file_name
      t.remove :avatar_content_type
      t.remove :avatar_file_size
      t.remove :avatar_updated_at
    end
  end

  def self.down
    change_table :users, :bulk => true do |t|
      t.string :avatar_updated_at
      t.string :avatar_file_size
      t.string :avatar_content_type
      t.string :avatar_file_name
      t.remove :avatar
    end
  end
end
