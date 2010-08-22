require 'spec_helper'

describe Board do
  before(:each) do
    $redis.flushdb
    Board.secret = "this is secret!"
  end

  let(:john) do
    user = stub("John Doe", :to_param => "john-doe")
    user.stub_chain(:account, :login).and_return("john")
    user
  end

  let(:news) do
    news = News.new
    news.stub(:id).and_return(123)
    news
  end

  it "can be initialized" do
    b = Board.new
    b.should respond_to(:id)
    b.should respond_to(:kind)
    b.kind.should == "chat"
    b.object_type.should == Board.free
    b.object_id.should be_nil
    b.message.should be_nil
    b = Board.new(:object_type => Board.news, :object_id => news.id, :message => "foobar")
    b.object_type.should == Board.news
    b.object_id.should == news.id
    b.message.should == "foobar"
  end

  it "has a build method on collection" do
    boards = Board.all(Board.writing)
    boards.should respond_to(:build)
    boards.build.object_type.should == Board.writing
    boards.build.object_id.should be_nil
    boards = Board.all(Board.news, news.id)
    boards.should respond_to(:build)
    boards.build.object_type.should == Board.news
    boards.build.object_id.should == news.id
  end

  it "can construct chan_key" do
    Board.chan_key(Board.free, nil).should == "boards/chans/free"
    b = Board.new(:object_type => Board.free)
    b.chan_key.should == "boards/chans/free"
    b = Board.new(:object_type => Board.news, :object_id => 123)
    b.chan_key.should == "boards/chans/news/123"
  end

  it "has a private_key that depends of the secret" do
    b = Board.new(:object_type => Board.news, :object_id => 123)
    b.private_key.should_not == Digest::SHA1.hexdigest("News/123/")
    Board.secret = nil
    b.private_key.should == Digest::SHA1.hexdigest("News/123/")
  end

  it "can construct the user_link" do
    b = Board.new
    b.user = john
    b.user_name.should == "john"
    b.user_url.should  == "/users/john-doe"
    b.user_link.should == '<a href="/users/john-doe">john</a>'
  end

  it "can't be possible to save a blank message" do
    b = Board.new(:object_type => Board.news, :object_id => 123, :message => "")
    b.user = john
    b.save.should be_false
    b = Board.new(:object_type => Board.news, :object_id => 123)
    b.user = john
    b.save.should be_false
  end

  it "can be saved and retrieved" do
    b = Board.new(:object_type => Board.news, :object_id => 123, :message => "foobar")
    b.user = john
    b.kind = "submission"
    b.user_agent = "console"
    b.save.should be_true
    boards = Board.all(Board.news, 123)
    boards.should have(1).item
    board = boards.first
    board.id.should > 0
    board.kind.should == "submission"
    board.message.should == "foobar"
    board.user_agent.should == "console"
    board.user_name.should == "john"
    board.user_url.should == "/users/john-doe"
    board.created_at.to_i.should > 0
    board.created_at.should > (Time.now - 10.seconds)
    board.created_at.should <= Time.now
  end

  it "has a special constructor for a board relative to a content" do
    b = Board.create_for(news, :user => john, :kind => "vote", :message => "foobar")
    b.object_type.should == Board.news
    b.object_id.should == news.id
    b.kind.should == "vote"
    b.user_name.should == "john"
    boards = Board.all(Board.news, news.id)
    boards.should have(1).item
    board = boards.first
    board.kind.should == "vote"
    board.message.should == "foobar"
    board.user_name.should == "john"
  end

  it "is sorted from the more recent to the older" do
    5.times do
      b = Board.new(:object_type => Board.free, :message => "foobar")
      b.user = john
      b.save.should be_true
    end
    boards = Board.all(Board.free)
    boards.should have(5).items
    boards[0].id.should == 5
    boards[1].id.should == 4
    boards[2].id.should == 3
    boards[3].id.should == 2
    boards[4].id.should == 1
  end

  it "should be limited to 200 messages" do
    250.times do
      b = Board.new(:object_type => Board.free, :message => "foobar")
      b.user = john
      b.save.should be_true
    end
    boards = Board.all(Board.free)
    boards.should have(200).items
    $redis.keys("boards/msg/*").should have(200).items
    $redis.llen("boards/chans/free").should == 200
  end

  it "publish to redis" do
    b = Board.new(:object_type => Board.free, :message => "foobar")
    b.user = john
    id = $redis.get("boards/id").to_i + 1

    require 'timeout'
    Timeout::timeout(1) do
      thread = Thread.new do
        r = Redis.new
        r.subscribe "b/#{b.private_key}/#{id}/chat" do |on|
          on.message do |chan,msg|
            @chan, @msg = chan, msg
            r.unsubscribe
          end
        end
      end

      b.save
      thread.join
    end

    @chan.should == "b/#{b.private_key}/#{id}/chat"
    @msg.should  =~ /john-doe/
    @msg.should  =~ /foobar/
  end

  context "ActiveModel Lint tests" do
    require 'test/unit/assertions'
    require 'active_model/lint'
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests

    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
      example m.gsub('_',' ') do
        send m
      end
    end

    def model
      Board.new
    end
  end
end
