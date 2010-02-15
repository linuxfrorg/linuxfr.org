require 'spec_helper'

describe Comment do
  it "should create a new instance given valid attributes" do
    Factory.create(:comment)
  end

  it "should wikify the body" do
    comment = Factory(:comment, :wiki_body => "''it'' et '''gras'''")
    comment.body.should == "<p><em>it</em> et <strong>gras</strong></p>\n"
  end

  context "in a simple thread" do
    before :each do
      @user = Factory(:user)
      @modo = Factory(:moderator)
      @root_one   = Factory(:comment, :user_id => @user.id)
      @root_two   = Factory(:comment, :user_id => @user.id)
      @parent_one = Factory(:comment, :user_id => @modo.id, :parent_id => @root_one.id)
      @child_one  = Factory(:comment, :user_id => @user.id, :parent_id => @parent_one.id)
      @child_two  = Factory(:comment, :user_id => @user.id, :parent_id => @parent_one.id)
      @parent_two = Factory(:comment, :user_id => @user.id, :parent_id => @root_one.id)
      @child_three= Factory(:comment, :user_id => @modo.id, :parent_id => @parent_one.id)
    end

    it "should be 2 roots" do
      @root_one.should be_root
      @root_two.should be_root
      @parent_one.should_not be_root
      @parent_two.should_not be_root
      @child_one.should_not be_root
      @child_two.should_not be_root
      @child_three.should_not be_root
    end

    it "should be answer to self when one of its ascendant is from the same user" do
      @root_one.should_not be_answer_to_self
      @root_two.should_not be_answer_to_self
      @parent_one.should_not be_answer_to_self
      @parent_two.should be_answer_to_self
      @child_one.should be_answer_to_self
      @child_two.should be_answer_to_self
      @child_three.should be_answer_to_self
    end
  end
end
