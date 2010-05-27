require 'spec_helper'

describe "News" do
  before(:each) do
    User.delete_all
    Account.delete_all
    Section.delete_all
    News.delete_all
    Node.delete_all
  end

  let!(:section) do
    Factory(:section).tap do |sect|
      sect.stub(:image).and_return(double('image', :url => ''))
    end
  end

  it "can be listed" do
    news = Factory.create(:news, :section_id => section.id)
    news.should be_valid
    get news_index_path
    assert_response :success
    response.should contain(news.title)
  end

  it "can be submitted" do
    get new_news_path
    fill_in :news_author_name, :with => "Pierre Tramo"
    fill_in :news_author_email, :with => "pierre.tramo@dlfp.org"
    fill_in :news_title, :with => "J2EE is so cool"
    select section.title
    fill_in :news_wiki_body, :with => "Really, you should try it!"
    click_button "Prévisualiser"
    assert_response :success
    response.should contain("J2EE is so cool")
    click_button "Soumettre"
    assert_response :success
    response.should contain("Votre proposition de dépêche a bien été soumise")
  end
end
