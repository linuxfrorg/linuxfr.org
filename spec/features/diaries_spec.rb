# encoding: UTF-8
require 'spec_helper'

describe "Diaries" do
  include Warden::Test::Helpers

  after(:each)  { Warden.test_reset! }

  let(:account) { FactoryGirl.create(:normal_account) }
  let(:modero)  { FactoryGirl.create(:moderator).account }
  let!(:diary)  { FactoryGirl.create(:diary) }

  it "can be listed and showed" do
    visit diaries_path
    status_code.should be(200)
    page.should have_content(diary.title)
    click_link "Lire la suite"
    status_code.should be(200)
    page.should have_content(diary.title)
  end

  it "can be submitted by an authenticated user" do
    title = "J'écris un journal"
    login_as account
    visit new_diary_path
    status_code.should be(200)
    fill_in :diary_title, with: title
    fill_in :diary_wiki_body, with: "bla bla bla"
    click_button "Prévisualiser"
    page.should have_content(title)
    click_button "Poster le journal"
    page.should have_content("Votre journal a bien été créé")
    page.should have_content(title)
  end

  it "can be edited by a moderator" do
    body = "Journal modifié"
    login_as modero
    visit url_for([diary.owner, diary])
    status_code.should be(200)
    within ".diary" do
      click_link "Modifier"
    end
    fill_in :diary_wiki_body, with: body
    click_button "Prévisualiser"
    click_button "Poster le journal"
    page.should have_content("Le journal a bien été modifié")
    page.should have_content(body)
  end

  context "Deleted diary" do
    before(:each) do
      diary.stub(:update_index)
      diary.mark_as_deleted
    end

    it "doesn't show the deleted diary" do
      visit url_for([diary.owner, diary])
      page.should have_content("Accès interdit à cette page !")
    end
  end
end
