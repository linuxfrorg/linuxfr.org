class AddIndexOnCreatedAtForNewsVersion < ActiveRecord::Migration
  def change
    add_index :news_versions, [:created_at]
  end
end
