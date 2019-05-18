class FixUsersNameToMatchAccountsLogin < ActiveRecord::Migration[4.2]
  def up
    execute "ALTER TABLE users MODIFY name varchar(40) NULL;"
  end

  def down
    execute "ALTER TABLE users MODIFY name varchar(32) NULL;"
  end

  def db_name
    Rails.configuration.database_configuration[Rails.env]['database']
  end
end
