class AddLastSeenAtToAccounts < ActiveRecord::Migration[5.2]
  def change
    # Use datetime type instead of date to be able to easily set default value
    # This is a restriction due to Mariadb < 10.2.1
    add_column :accounts, :last_seen_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
