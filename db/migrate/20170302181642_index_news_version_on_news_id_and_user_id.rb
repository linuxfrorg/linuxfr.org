class IndexNewsVersionOnNewsIdAndUserId < ActiveRecord::Migration
  def change
    add_index :news_versions, [:news_id, :user_id]
  end
end
