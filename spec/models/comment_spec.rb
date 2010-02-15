require 'spec_helper'

describe Comment do
  it "should create a new instance given valid attributes" do
    Factory.create(:comment)
  end

  it "should wikify the body" do
    comment = Factory(:comment, :wiki_body => "''it'' et '''gras'''")
    comment.body.should == "<p><em>it</em> et <strong>gras</strong></p>\n"
  end
end
