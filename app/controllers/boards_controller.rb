class BoardsController < ApplicationController
  before_filter :authenticate_account!
  after_filter :expire_cache, :only => [:create]
  caches_page :show, :if => Proc.new { |c| c.request.format.xml? }
  respond_to :html, :atom

  def show
    @boards = Board.all(Board.free)
    @board  = @boards.build
    enforce_view_permission(@board)
    respond_with(@boards)
  end

  def create
    board = Board.new(params[:board])
    board.user = current_account.user
    enforce_view_permission(board)
    board.message    = board_auto_link(board.message)
    board.user_agent = request.user_agent
    board.save
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js   { render :nothing => true }
    end
  end

protected

  def board_auto_link(msg)
    self.class.helpers.auto_link(msg, :all) { "[URL]" }
  end

  def expire_cache
    expire_page :action => :show, :format => :xml
  end
end
