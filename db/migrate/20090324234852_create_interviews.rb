class CreateInterviews < ActiveRecord::Migration
  def self.up
    create_table :interviews do |t|
      t.string :state, :null => false, :default => 'draft'
      t.string :title
      t.text :body
      t.references :news
      t.references :assigned_to_user
      t.timestamps
    end
  end

  def self.down
    drop_table :interviews
  end
end
