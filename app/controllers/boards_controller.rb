# encoding: utf-8
class BoardsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_referer_or_authenticity_token, only: [:create]
  before_action :authenticate_account!, only: :create
  after_action :expire_cache, only: [:create]
  caches_page :show, if: Proc.new { |c| c.request.format.xml? }
  respond_to :html, :xml

  def show
    @boards = Board.all(Board.free)
    respond_with(@boards)
  end

  def create
    board = Board.new board_params
    board.user = current_account.user
    enforce_create_permission(board)
    board.user_agent = request.user_agent
    board.save
    board.news.tap {|news| news.node.read_by current_account.id if news }
    respond_to do |wants|
      wants.html { redirect_to :back rescue redirect_to root_url }
      wants.js   { render nothing: true }
    end
  end

protected

  def board_params
    params.require(:board).permit(:object_type, :object_id, :message)
  end

  def verify_referer_or_authenticity_token
    request.referer =~ /^https?:\/\/#{MY_DOMAIN}\// or verify_authenticity_token
  end

  def expire_cache
    expire_page action: :show
  end
end
