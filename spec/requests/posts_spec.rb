require 'spec_helper'

describe "Posts" do
  include Warden::Test::Helpers

  before(:each) do
    User.delete_all
    Account.delete_all
    Post.delete_all
    Forum.delete_all
    Node.delete_all
  end

  after(:each)  { Warden.test_reset! }

  let(:account) { Factory.create(:account) }
  let(:modero)  { Factory.create(:moderator).account }
  let!(:post)   { Factory.create(:post) }
  let(:forum)   { post.forum }

  it "can be listed and showed" do
    get forums_path
    assert_response :success
    response.should contain(post.title)
    click_link forum.title
    assert_response :success
    response.should contain(post.title)
    click_link "Lire la suite"
    assert_response :success
    response.should contain(post.title)
  end

  it "can be submitted by an authenticated user" do
    title = "Je demande de l'aide"
    login_as account
    get new_post_path
    assert_response :success
    select forum.title
    fill_in :post_title, :with => title
    fill_in :post_wiki_body, :with => "bla bla bla"
    click_button "Prévisualiser"
    response.should contain(title)
    click_button "Poster le message"
    response.should contain("Votre message a bien été créé")
    response.should contain(title)
  end

  it "can be edited by a moderator" do
    body = "Message modifié"
    login_as modero
    get url_for([forum, post])
    assert_response :success
    within ".post" do
      click_link "Modifier"
    end
    fill_in :post_wiki_body, :with => body
    click_button "Prévisualiser"
    click_button "Poster le message"
    response.should contain("Votre message a bien été modifié")
    response.should contain(body)
  end
end
