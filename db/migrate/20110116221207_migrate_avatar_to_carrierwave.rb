class MigrateAvatarToCarrierwave < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar, :string
    remove_column :users, :avatar_file_name
    remove_column :users, :avatar_content_type
    remove_column :users, :avatar_file_size
    remove_column :users, :avatar_updated_at
  end

  def self.down
    add_column :users, :avatar_updated_at
    add_column :users, :avatar_file_size
    add_column :users, :avatar_content_type
    add_column :users, :avatar_file_name
    remove_column :users, :avatar
  end
end
