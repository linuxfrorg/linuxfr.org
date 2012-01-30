class UpdateToDevise20 < ActiveRecord::Migration

  def change
    change_table :accounts do |t|
      t.datetime :reset_password_sent_at
      t.remove :remember_token
    end
  end

end
