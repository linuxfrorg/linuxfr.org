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
      wants.html { redirect_to :back }
      wants.js   { render :nothing }
    end
  end

end
