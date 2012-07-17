class RemoveGravatarHashToUsers < ActiveRecord::Migration
  def up
    remove_column :users, :gravatar_hash
  end

  def down
    add_column :users, :gravatar_hash, :string, :limit => 32
  end
end
