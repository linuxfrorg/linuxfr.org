class WeHaveSomeReallyLongTitles < ActiveRecord::Migration
  def self.up
    change_column :comments, :title,       :string, :limit => 160, :null => false
    change_column :diaries,  :title,       :string, :limit => 160, :null => false
    change_column :diaries,  :cached_slug, :string, :limit => 165
    change_column :posts,    :title,       :string, :limit => 160, :null => false
    change_column :posts,    :cached_slug, :string, :limit => 165
  end

  def self.down
    change_column :comments, :title,       :string, :limit => 100, :null => false
    change_column :diaries,  :title,       :string, :limit => 100, :null => false
    change_column :diaries,  :cached_slug, :string, :limit => 105
    change_column :posts,    :title,       :string, :limit => 100, :null => false
    change_column :posts,    :cached_slug, :string, :limit => 105
  end
end
