class AddMastodonUrlToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mastodon_url, :string
  end
end
