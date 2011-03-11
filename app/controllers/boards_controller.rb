class BoardsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :verify_referer_or_authenticity_token, :only => [:create]
  before_filter :authenticate_account!, :only => :create
  after_filter :expire_cache, :only => [:create]
  caches_page :show, :if => Proc.new { |c| c.request.format.xml? }
  respond_to :html, :xml

  def show
    @boards = Board.all(Board.free)
    @board  = @boards.build
    respond_with(@boards)
  end

  def create
    board = Board.new(params[:board])
    board.user       = current_account.user
    enforce_create_permission(board)
    board.user_agent = request.user_agent
    board.save
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js   { render :nothing => true }
    end
  end

protected

  def verify_referer_or_authenticity_token
    request.referer =~ /^https?:\/\/#{MY_DOMAIN}\// or verify_authenticity_token
  end

  def expire_cache
    expire_page :action => :show, :format => :xml
  end
end
