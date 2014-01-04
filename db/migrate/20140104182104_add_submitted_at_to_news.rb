class AddSubmittedAtToNews < ActiveRecord::Migration
  def up
    add_column :news, :submitted_at, :datetime
    News.reset_column_information
    News.update_all("submitted_at=created_at")
    News.where("created_at > '2011-02-28'").each do |news|
      message = Board.all(Board.news, news.id).detect {|m| m.message == "<b>La dépêche a été soumise à la modération</b>" }
      news.update_column(:submitted_at, message.created_at) if message
    end
  end

  def down
    remove_column :news, :submitted_at
  end
end
