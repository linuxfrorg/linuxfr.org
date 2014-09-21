# encoding: UTF-8
require 'spec_helper'

describe "News" do
  before(:each) do
    Lang['fr'] = 'Français'
    Lang['en'] = 'Anglais'
  end

  let!(:section) do
    FactoryGirl.create(:section).tap do |sect|
      allow(sect).to receive(:image).and_return(double('image', url: ''))
    end
  end

  it "can be listed" do
    news = FactoryGirl.create(:news, section_id: section.id)
    news.should be_valid
    visit news_index_path
    status_code.should be(200)
    page.should have_content(news.title)
  end

  it "can be submitted" do
    visit new_news_path
    fill_in :news_author_name, with: "Pierre Tramo"
    fill_in :news_author_email, with: "pierre.tramo@dlfp.org"
    fill_in :news_title, with: "J2EE is so cool"
    select section.title
    fill_in :news_wiki_body, with: "Really, you should try it!"
    click_button "Prévisualiser"
    status_code.should be(200)
    page.should have_content("J2EE is so cool")
    click_button "Soumettre"
    status_code.should be(200)
    page.should have_content("Votre proposition de dépêche a bien été soumise")
  end
end
