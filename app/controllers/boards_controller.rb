class BoardsController < ApplicationController
  before_filter :user_required

  def index
    @board = Board[params[:id]]
    raise ActiveRecord::RecordNotFound unless @board && @board.accessible_by?(current_user)
    @boards = Board.scoped_by_type(@board.object_type).all
    respond_to do |wants|
      wants.html
      wants.xml
    end
  end

  def add
    # FIXME we should also keep the current_user.id
    @board = Board.new(params[:board])
    @board.message    = board_auto_link(@board.message)
    @board.login      = current_user.login
    @board.user_agent = request.user_agent
    @board.save
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js   { render :nothing }
    end
  end

protected

  def board_auto_link(msg)
    self.class.helpers.auto_link(msg, :all) { "[URL]" }
  end
end
