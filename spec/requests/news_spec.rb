require 'spec_helper'

describe "News" do
  let(:section) { Factory(:section) }

  it "can be listed" do
    news = Factory(:news, :section_id => section.id)
    get news_index_path
    response.should contain(news.title)
  end

  it "can be submitted" do
    section.should be_published
    get new_news_path
    fill_in :news_author_name, :with => "Pierre Tramo"
    fill_in :news_author_email, :with => "pierre.tramo@dlfp.org"
    fill_in :news_title, :with => "J2EE is so cool"
    select section.title
    fill_in :news_wiki_body, :with => "Really, you should try it!"
    click_button "Prévisualiser"
    response.should contain("J2EE is so cool")
    click_button "Soumettre"
    response.should contain("Votre proposition de dépêche a bien été soumise")
  end
end
