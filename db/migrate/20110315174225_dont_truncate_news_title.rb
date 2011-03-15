class DontTruncateNewsTitle < ActiveRecord::Migration
  def self.up
    change_column :news, :title,       :string, :limit => 160, :null => false
    change_column :news, :cached_slug, :string, :limit => 165
  end

  def self.down
    change_column :news, :title,       :string, :limit => 100, :null => false
    change_column :news, :cached_slug, :string, :limit => 105
  end
end
