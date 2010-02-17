require 'spec_helper'

describe Thread do
  before(:each) do
    @user_id = Factory(:user).id
    @node_id = 1
  end

  it "should create an empty thread when no comments" do
    Threads.all(@node_id).should be_empty
  end

  it "should create a thread with the only comment" do
    @root = Factory(:comment, :user_id => @user_id, :node_id => @node_id)
    threads = Threads.all(@node_id)
    threads.size.should == 1
    threads.first.comment.should == @root
    threads.first.children.should be_empty
  end

  context "in a simple discussion" do
    before :each do
      @root_one   = Factory(:comment, :user_id => @user_id, :node_id => @node_id)
      @root_two   = Factory(:comment, :user_id => @user_id, :node_id => @node_id)
      @parent_one = Factory(:comment, :user_id => @user_id, :node_id => @node_id, :parent_id => @root_one.id)
      @child_one  = Factory(:comment, :user_id => @user_id, :node_id => @node_id, :parent_id => @parent_one.id)
      @child_two  = Factory(:comment, :user_id => @user_id, :node_id => @node_id, :parent_id => @parent_one.id)
      @parent_two = Factory(:comment, :user_id => @user_id, :node_id => @node_id, :parent_id => @root_one.id)
      @child_three= Factory(:comment, :user_id => @user_id, :node_id => @node_id, :parent_id => @parent_one.id)
    end

    it "should create the complete threads" do
      threads = Threads.all(@node_id)
      threads.size.should == 2
        first_thread = threads.first
        first_thread.comment.should == @root_one
        first_thread.children.size.should == 2
          first_parent = first_thread.children.first
          first_parent.comment.should == @parent_one
          first_parent.children.size == 3
            first_child = first_parent.children.first
            first_child.comment == @child_one
            first_child.children.should be_empty
            second_child = first_parent.children.first
            second_child.comment == @child_two
            second_child.children.should be_empty
            third_child = first_parent.children.first
            third_child.comment == @child_three
            third_child.children.should be_empty
          second_parent = first_thread.children.second
          second_parent.comment.should == @parent_two
          second_parent.children.should be_empty
        last_thread = threads.last
        last_thread.comment.should == @root_two
        last_thread.children.should be_empty
    end
  end
end
