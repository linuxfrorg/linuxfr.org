class BoardsController < ApplicationController
  before_filter :authenticate_account!

  def show
    @board = Board[Board.free]
    enforce_view_permission(@board)
    @boards = Board.by_kind(@board.object_type)
    respond_to do |wants|
      wants.html
      wants.xml
    end
  end

  def add
    board = current_user.boards.build(params[:board])
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

end
