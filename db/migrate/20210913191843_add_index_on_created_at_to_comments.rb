class AddIndexOnCreatedAtToComments < ActiveRecord::Migration[5.2]
  def change
    add_index :comments, [:created_at], order: {created_at: :desc}
  end
end
