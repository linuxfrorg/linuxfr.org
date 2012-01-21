# encoding: UTF-8
require 'spec_helper'

describe "Diaries" do
  include Warden::Test::Helpers

  after(:each)  { Warden.test_reset! }

  let(:account) { FactoryGirl.create(:normal_account) }
  let(:modero)  { FactoryGirl.create(:moderator).account }
  let!(:diary)  { FactoryGirl.create(:diary) }

  it "can be listed and showed" do
    get diaries_path
    assert_response :success
    response.should contain(diary.title)
    click_link "Lire la suite"
    assert_response :success
    response.should contain(diary.title)
  end

  it "can be submitted by an authenticated user" do
    title = "J'écris un journal"
    login_as account
    get new_diary_path
    assert_response :success
    fill_in :diary_title, :with => title
    fill_in :diary_wiki_body, :with => "bla bla bla"
    click_button "Prévisualiser"
    response.should contain(title)
    click_button "Poster le journal"
    response.should contain("Votre journal a bien été créé")
    response.should contain(title)
  end

  it "can be edited by a moderator" do
    body = "Journal modifié"
    login_as modero
    get url_for([diary.owner, diary])
    assert_response :success
    within ".diary" do
      click_link "Modifier"
    end
    fill_in :diary_wiki_body, :with => body
    click_button "Prévisualiser"
    click_button "Poster le journal"
    response.should contain("Le journal a bien été modifié")
    response.should contain(body)
  end
end
