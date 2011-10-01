class RenameMouleInVisitor < ActiveRecord::Migration
  def up
    change_column_default :accounts, :role, 'visitor'
    execute "UPDATE accounts SET role='visitor' WHERE role='moule'"
  end

  def down
    change_column_default :accounts, :role, 'moule'
    execute "UPDATE accounts SET role='moule' WHERE role='visitor'"
  end
end
