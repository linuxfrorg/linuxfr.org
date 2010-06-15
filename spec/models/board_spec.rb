require 'spec_helper'

describe Board do
  before(:each) do
    $redis.flushdb
  end

  it "can be initialized" do
    b = Board.new
    b.should respond_to(:id)
    b.should respond_to(:kind)
    b.kind.should == "chat"
    b.object_type.should == Board.free
    b.object_id.should be_nil
    b.message.should be_nil
    b = Board.new(:object_type => Board.news, :object_id => 123, :message => "foobar")
    b.object_type.should == Board.news
    b.object_id.should == 123
    b.message.should == "foobar"
  end

  it "has a build method on collection" do
    boards = Board.all(Board.writing)
    boards.should respond_to(:build)
    boards.build.object_type.should == Board.writing
    boards.build.object_id.should be_nil
    boards = Board.all(Board.news, 123)
    boards.should respond_to(:build)
    boards.build.object_type.should == Board.news
    boards.build.object_id.should == 123
  end

  it "can construct chan_key" do
    Board.chan_key(Board.free, nil).should == "boards/chans/free"
    b = Board.new(:object_type => Board.free)
    b.chan_key == "boards/chans/free"
    b = Board.new(:object_type => Board.news, :object_id => 123)
    b.chan_key == "boards/chans/news/123"
  end
end
