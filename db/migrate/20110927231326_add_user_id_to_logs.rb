class AddUserIdToLogs < ActiveRecord::Migration
  def change
    add_column    :logs, :user_id, :integer
    remove_column :logs, :updated_at
  end
end
