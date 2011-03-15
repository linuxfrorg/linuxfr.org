# == Schema Information
#
# Table name: comments
#
#  id                :integer(4)      not null, primary key
#  node_id           :integer(4)
#  user_id           :integer(4)
#  state             :string(10)      default("published"), not null
#  title             :string(160)     not null
#  score             :integer(4)      default(0), not null
#  answered_to_self  :boolean(1)      default(FALSE), not null
#  materialized_path :string(1022)
#  body              :text
#  wiki_body         :text
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe Comment do
  before(:each) do
    User.delete_all
    Account.delete_all
    Comment.delete_all
  end

  it "is valid" do
    Factory.build(:comment).should be_valid
  end

  it "wikifies the body" do
    comment = Factory(:comment, :wiki_body => "_it_ et **gras**")
    comment.body.should == "<p><em>it</em> et <strong>gras</strong></p>"
  end

  context "in a simple thread" do
    before :each do
      @user = Factory(:user)
      @modo = Factory(:moderator)
      @root_one   = Factory(:comment, :id => 1,:user_id => @user.id)
      @root_two   = Factory(:comment, :id => 2,:user_id => @user.id)
      @parent_one = Factory(:comment, :id => 3,:user_id => @modo.id, :parent_id => @root_one.id)
      @child_one  = Factory(:comment, :id => 4,:user_id => @user.id, :parent_id => @parent_one.id)
      @child_two  = Factory(:comment, :id => 5,:user_id => @user.id, :parent_id => @parent_one.id)
      @parent_two = Factory(:comment, :id => 6,:user_id => @user.id, :parent_id => @root_one.id)
      @child_three= Factory(:comment, :id => 7,:user_id => @modo.id, :parent_id => @parent_one.id)
    end

    it "has 2 roots" do
      @root_one.should be_root
      @root_two.should be_root
      @parent_one.should_not be_root
      @parent_two.should_not be_root
      @child_one.should_not be_root
      @child_two.should_not be_root
      @child_three.should_not be_root
    end

    it "is marked as answer to self when one of its ascendant is from the same user" do
      @root_one.should_not be_answer_to_self
      @root_two.should_not be_answer_to_self
      @parent_one.should_not be_answer_to_self
      @parent_two.should be_answer_to_self
      @child_one.should be_answer_to_self
      @child_two.should be_answer_to_self
      @child_three.should be_answer_to_self
    end

    it "has correct depth" do
      @root_one.depth.should be_equal(0)
      @root_two.depth.should be_equal(0)
      @parent_one.depth.should be_equal(1)
      @parent_two.depth.should be_equal(1)
      @child_one.depth.should be_equal(2)
      @child_two.depth.should be_equal(2)
      @child_three.depth.should be_equal(2)
    end

    it "has correct materialized_path" do
      @root_one.materialized_path.should == "000000000001"
      @root_two.materialized_path.should == "000000000002"
      @parent_one.materialized_path.should == "000000000001000000000003"
      @parent_two.materialized_path.should == "000000000001000000000006"
      @child_one.materialized_path.should == "000000000001000000000003000000000004"
      @child_two.materialized_path.should == "000000000001000000000003000000000005"
      @child_three.materialized_path.should == "000000000001000000000003000000000007"
    end

    it "has correct parent_id" do
      Comment.find(@root_one.id).parent_id.should == 0
      Comment.find(@root_two.id).parent_id.should == 0
      Comment.find(@parent_one.id).parent_id.should == @root_one.id
      Comment.find(@parent_two.id).parent_id.should == @root_one.id
      Comment.find(@child_one.id).parent_id.should == @parent_one.id
      Comment.find(@child_two.id).parent_id.should == @parent_one.id
      Comment.find(@child_three.id).parent_id.should == @parent_one.id
    end

    it "has correct nb_answers" do
      @root_one.nb_answers.should be_equal(5)
      @root_two.nb_answers.should be_equal(0)
      @parent_one.nb_answers.should be_equal(3)
      @parent_two.nb_answers.should be_equal(0)
      @child_one.nb_answers.should be_equal(0)
      @child_two.nb_answers.should be_equal(0)
      @child_three.nb_answers.should be_equal(0)
    end

    it "finds the last answer" do
      @root_one.last_answer.should == @child_three
      @root_two.last_answer.should == nil
      @parent_one.last_answer.should == @child_three
      @parent_two.last_answer.should == nil
      @child_one.last_answer.should == nil
      @child_two.last_answer.should == nil
      @child_three.last_answer.should == nil
    end
  end
end
