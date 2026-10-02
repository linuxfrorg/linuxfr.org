class AddDeltachatIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :deltachat_id, :string
  end
end
