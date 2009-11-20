class BoardsController < ApplicationController
  before_filter :user_required

  def show
    @board = Board[params[:id]]
    raise ActiveRecord::RecordNotFound unless @board && @board.accessible_by?(current_user)
    @boards = Board.by_type(@board.object_type)
    respond_to do |wants|
      wants.html
      wants.xml
    end
  end

  def add
    board = Board.new(params[:board])
    raise ActiveRecord::RecordNotFound unless board && board.accessible_by?(current_user)
    board.message    = board_auto_link(board.message)
    board.user_id    = current_user.id
    board.user_agent = request.user_agent
    board.save
    Chat.create(board.id, board.chan, render_to_string(board)) rescue nil
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
