# encoding: utf-8
class BoardsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_account!, only: :create
  after_action :expire_cache, only: [:create]
  caches_page :show, if: Proc.new { |c| c.request.format.xml? }
  respond_to :html, :xml, :tsv

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
      wants.html { redirect_back fallback_location: root_url }
      wants.js   { head :created }
      wants.xml  { head :created }
      wants.tsv  { head :created }
    end
  end

protected

  def board_params
    params.require(:board).permit(:object_type, :object_id, :message)
  end

  def expire_cache
    expire_page action: :show, format: :xml
  end
end
