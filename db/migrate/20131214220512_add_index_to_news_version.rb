class AddIndexToNewsVersion < ActiveRecord::Migration
  def change
    add_index :news_versions, :user_id
  end
end
