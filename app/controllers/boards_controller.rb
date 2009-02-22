class BoardsController < ApplicationController
  before_filter :login_required

  def index
    @board = Board[params[:id]]
    raise ActiveRecord::RecordNotFound unless @board && @board.accessible_by?(current_user)
    @boards = Board.by_type(@board.object_type).all
    respond_to do |wants|
      wants.html
      wants.xml # TODO
    end
  end

  def add
    @board = Board.new(params[:board])
    @board.user = current_user
    @board.save
    respond_to do |wants|
      wants.html { redirect_to board_url(@board) }
      wants.js   { render :nothing }
    end
  end

protected

  def board_url(board)
    case board.object_type
    when Board.news:    moderation_news_url(board.object)
    when Board.amr:     moderation_news_index_url
    when Board.writing: writing_board_url
    when Board.free:    free_board_url
    else                root_url
    end
  end

end
