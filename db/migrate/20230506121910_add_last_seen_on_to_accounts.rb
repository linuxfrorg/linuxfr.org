class AddLastSeenOnToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :last_seen_on, :date

    reversible do |set_last_seen_on|
      set_last_seen_on.up do
        # Set default value only for confirmed accounts
        execute <<-SQL
          UPDATE accounts
            SET last_seen_on =
              CASE
                WHEN confirmed_at is NULL
                  THEN NULL
                WHEN login in ("Anonyme", "Collectif")
                  THEN NULL
                ELSE
                  CURRENT_DATE()
                END
        SQL
      end
      set_last_seen_on.down do
        # Column will be dropped nothing to do
      end
    end
  end
end
