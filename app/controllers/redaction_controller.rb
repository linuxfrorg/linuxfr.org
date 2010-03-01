class RedactionController < ApplicationController
  before_filter :writer_required

  def index
    @board = Board[Board.writing]
    enforce_view_permission(@board)
    @boards = Board.by_kind(@board.object_type)
    @news   = News.draft.sorted.all(:limit => 3)
  end
end
