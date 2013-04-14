class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :country
      t.string :email
      t.timestamps
    end
  end
end
