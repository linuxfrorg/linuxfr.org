class CreatePollAnswers < ActiveRecord::Migration
  def self.up
    create_table :poll_answers do |t|
      t.references :poll
      t.string :answer, :null => false, :limit => 128
      t.integer :votes, :null => false, :default => 0
      t.integer :position
      t.timestamps
    end
    add_index :poll_answers, [:poll_id, :position]
  end

  def self.down
    drop_table :poll_answers
  end
end
