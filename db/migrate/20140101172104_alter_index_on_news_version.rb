class AlterIndexOnNewsVersion < ActiveRecord::Migration
  def change
    remove_index :news_versions, :user_id
    add_index :news_versions, [:user_id, :created_at]
  end
end
