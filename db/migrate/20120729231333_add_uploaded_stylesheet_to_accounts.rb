class AddUploadedStylesheetToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :uploaded_stylesheet, :string
  end
end
