class RemoveStylesheetsFromAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :accounts, :uploaded_stylesheet, :string
    remove_column :accounts, :stylesheet, :string
  end
end
