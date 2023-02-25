class DropBadges < ActiveRecord::Migration[5.2]
  def self.up
    drop_table :badges
  end

  def self.down
    create_table :badges do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :country
      t.string :email
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
