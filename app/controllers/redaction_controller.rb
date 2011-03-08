class RedactionController < ApplicationController
  before_filter :writer_required

  def index
    @boards = Board.all(Board.writing)
    @board  = @boards.build
    enforce_view_permission(@board)
    @news   = News.draft.sorted
  end
end
