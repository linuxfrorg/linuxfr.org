class CreateInterviews < ActiveRecord::Migration
  def self.up
    create_table :interviews do |t|
      t.string :state, :null => false, :default => 'draft'
      t.string :title
      t.string :cached_slug
      t.text :body
      t.text :wiki_body
      t.references :news
      t.references :assigned_to_user
      t.timestamps
    end
    add_index :interviews, :cached_slug
    add_index :interviews, :state
  end

  def self.down
    drop_table :interviews
  end
end
