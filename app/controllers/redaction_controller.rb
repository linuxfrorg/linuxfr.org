class RedactionController < ApplicationController
  before_filter :writer_required
  append_view_path NoNamespaceResolver.new

  def index
    @boards = Board.all(Board.writing)
    @board  = @boards.build
    enforce_view_permission(@board)
    @news   = News.draft.sorted
  end
end
