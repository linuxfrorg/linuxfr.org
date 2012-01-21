# encoding: utf-8
require 'spec_helper'

describe "Posts" do
  include Warden::Test::Helpers

  before(:each) do
    User.delete_all
    Account.delete_all
    Post.delete_all
    Forum.delete_all
    Node.delete_all
    Comment.delete_all
  end

  after(:each)  { Warden.test_reset! }

  let(:account) { FactoryGirl.create(:normal_account) }
  let(:modero)  { FactoryGirl.create(:moderator).account }
  let!(:post)   { FactoryGirl.create(:post) }
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
end
