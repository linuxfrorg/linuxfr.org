class AddMinMaxKarmaToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :min_karma, :int, :default => 20
    add_column :accounts, :max_karma, :int, :default => 20
  end
end
