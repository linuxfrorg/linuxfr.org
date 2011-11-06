class RemoveLockedById < ActiveRecord::Migration
  def change
    remove_column :links,      :locked_by_id
    remove_column :paragraphs, :locked_by_id
  end
end
