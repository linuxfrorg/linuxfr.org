class AddConvertedNewsIdToDiaries < ActiveRecord::Migration
  def change
    add_column :diaries, :converted_news_id, :integer
  end
end
