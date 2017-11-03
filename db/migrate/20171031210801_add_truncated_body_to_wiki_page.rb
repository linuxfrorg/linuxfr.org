class AddTruncatedBodyToWikiPage < ActiveRecord::Migration
  def change
    add_column :wiki_pages, :truncated_body, :text
    WikiPage.all.each do |wiki_page|
        wiki_page.update_attribute :truncated_body, LFTruncator.truncate(wiki_page.body, nb_words=80)
    end
  end
end
