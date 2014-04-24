# encoding: utf-8

require 'spec_helper'

describe Board do
  let(:john) do
    user = double("John Doe", to_param: "john-doe", name: "John Doe")
    user.stub_chain(:account, :login).and_return("john")
    user
  end

  let(:news) do
    news = News.new
    news.stub(:id).and_return(123)
    News.stub(:find).with(123).and_return(news)
    news
  end

  it "can be initialized" do
    b = Board.new
    b.should respond_to(:id)
    b.object_type.should == Board.free
    b.object_id.should be_nil
    b.message.should be_nil
    b = Board.new(object_type: Board.news, object_id: news.id, message: "foobar")
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
    b = Board.new(object_type: Board.free)
    b.chan_key.should == "boards/chans/free"
    b = Board.new(object_type: Board.news, object_id: news.id)
    b.chan_key.should == "boards/chans/news/123"
  end

  it "can construct the user_link" do
    b = Board.new
    b.user = john
    b.user_name.should == "john"
    b.user_url.should  == "/users/john-doe"
    b.user_link.should == '<a href="/users/john-doe">john</a>'
  end

  it "can't be possible to save a blank message" do
    b = Board.new(object_type: Board.news, object_id: news.id, message: "")
    b.user = john
    b.save.should be_false
    b = Board.new(object_type: Board.news, object_id: news.id)
    b.user = john
    b.save.should be_false
  end

  it "can be saved and retrieved" do
    b = Board.new(object_type: Board.news, object_id: news.id, message: "foobar")
    b.user = john
    b.user_agent = "console"
    b.save.should be_true
    boards = Board.all(Board.news, news.id)
    boards.should have(1).item
    board = boards.first
    board.id.should > 0
    board.message.should == "foobar"
    board.user_agent.should == "console"
    board.user_name.should == "John Doe"
    board.user_url.should == "/users/john-doe"
    board.created_at.to_i.should > 0
    board.created_at.should > (Time.now - 10.seconds)
    board.created_at.should <= Time.now
  end

  it "is sorted from the more recent to the older" do
    5.times do
      b = Board.new(object_type: Board.free, message: "foobar")
      b.user = john
      b.user_agent = "console"
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

  it "should be limited to 100 messages" do
    110.times do
      b = Board.new(object_type: Board.free, message: "foobar")
      b.user = john
      b.user_agent = "console"
      b.save
    end
    boards = Board.all(Board.free)
    boards.should have(100).items
    $redis.keys("boards/msg/*").should have(100).items
    $redis.llen("boards/chans/free").should == 100
  end

  context "Sanitizing messages" do
    let(:board) { Board.new }

    it "escapes tags (escape the allowed ones)" do
      str = '<p>foo</p> <script type="javascript">alert("foo");</script> <blink>bar'
      sanitized = board.sanitize_message(str)
      sanitized.should == str.gsub('<', '&lt;').gsub('>', '&gt;')
    end

    it "keeps the allowed tags" do
      str = "<b>foo</b> <code>bar</code> <u><s>baz <i>qux</i></s> quux</u>"
      sanitized = board.sanitize_message(str)
      sanitized.should == str
    end

    it "links automatically URL" do
      str = "<b>foo</b> http://linuxfr.org/"
      sanitized = board.sanitize_message(str)
      sanitized.should == '<b>foo</b> <a href="http://linuxfr.org/">[url]</a>'
    end

    it "let us play with ducks" do
      str = "NoNo< --> \\_o< p4n!"
      sanitized = board.sanitize_message(str)
      sanitized.should == "NoNo&lt; --&gt; \\_o&lt; p4n!"
    end

    it "doesn't bug on multiple tags" do
      str = "<b>foo</b> bar <b>baz</b>"
      sanitized = board.sanitize_message(str)
      sanitized.should == "<b>foo</b> bar <b>baz</b>"
    end
  end

  context "ActiveModel Lint tests" do
    require 'active_model/lint'
    include ActiveModel::Lint::Tests

    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map(&:to_s).grep(/^test/).each do |m|
      example m.gsub('_', ' ') do
        send m
      end
    end

    def model
      Board.new
    end
  end
end
