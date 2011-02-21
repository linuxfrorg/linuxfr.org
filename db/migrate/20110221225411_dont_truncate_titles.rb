class DontTruncateTitles < ActiveRecord::Migration
  def self.up
    change_column :comments,   :title,       :string, :limit => 100, :null => false
    change_column :diaries,    :title,       :string, :limit => 100, :null => false
    change_column :diaries,    :cached_slug, :string, :limit => 105
    change_column :news,       :title,       :string, :limit => 100, :null => false
    change_column :news,       :cached_slug, :string, :limit => 105
    change_column :posts,      :title,       :string, :limit => 100, :null => false
    change_column :posts,      :cached_slug, :string, :limit => 105
    change_column :trackers,   :title,       :string, :limit => 100, :null => false
    change_column :trackers,   :cached_slug, :string, :limit => 105
    change_column :wiki_pages, :title,       :string, :limit => 100, :null => false
    change_column :wiki_pages, :cached_slug, :string, :limit => 105
  end

  def self.down
    change_column :wiki_pages, :cached_slug, :string, :limit => 64
    change_column :wiki_pages, :title,       :string, :limit => 64, :null => false
    change_column :trackers,   :cached_slug, :string, :limit => 64
    change_column :trackers,   :title,       :string, :limit => 64, :null => false
    change_column :posts,      :cached_slug, :string, :limit => 64
    change_column :posts,      :title,       :string, :limit => 64, :null => false
    change_column :news,       :cached_slug, :string, :limit => 64
    change_column :news,       :title,       :string, :limit => 64, :null => false
    change_column :diaries,    :cached_slug, :string, :limit => 64
    change_column :diaries,    :title,       :string, :limit => 64, :null => false
    change_column :comments,   :title,       :string, :limit => 32, :null => false
  end
end
