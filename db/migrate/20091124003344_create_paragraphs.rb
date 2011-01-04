class CreateParagraphs < ActiveRecord::Migration
  def self.up
    create_table :paragraphs do |t|
      t.references :news, :null => false
      t.integer :position
      t.boolean :second_part
      t.references :locked_by
      t.text :body
      t.text :wiki_body
    end
    add_index :paragraphs, [:news_id, :second_part, :position], :name => "index_paragraphs_on_news_id_and_more"
  end

  def self.down
    drop_table :paragraphs
  end
end
