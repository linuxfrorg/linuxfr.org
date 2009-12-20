class RedactionController < ApplicationController
  before_filter :writer_required

  def index
    @board = Board[Board.writing]
    raise ActiveRecord::RecordNotFound unless @board && @board.accessible_by?(current_user)
    @boards = Board.by_kind(@board.object_type)
    @news   = News.draft.sorted.all(:limit => 3)
  end
end
