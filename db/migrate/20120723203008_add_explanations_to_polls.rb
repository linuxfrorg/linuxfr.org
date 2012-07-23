class AddExplanationsToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :wiki_explanations, :text
    add_column :polls, :explanations, :text
  end
end
