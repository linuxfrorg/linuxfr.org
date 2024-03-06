class AddShowEmailToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :show_email, :boolean, default: false
  end
end
