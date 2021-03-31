class FixAssignedUserIdFromTracker < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    UPDATE trackers
    SET assigned_to_user_id = (SELECT user_id FROM accounts WHERE accounts.id = trackers.assigned_to_user_id)
    WHERE assigned_to_user_id is NOT NULL;
    SQL
  end

  def down
    execute <<-SQL
    UPDATE trackers
    SET assigned_to_user_id = (SELECT id FROM accounts WHERE accounts.user_id = trackers.assigned_to_user_id)
    WHERE assigned_to_user_id is NOT NULL;
    SQL
  end
end
