class RemoveOldPasswordFromAccounts < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.remove :old_password
    end
  end
end
