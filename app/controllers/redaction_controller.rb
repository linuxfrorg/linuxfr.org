# encoding: utf-8
class RedactionController < ApplicationController
  before_filter :authenticate_account!
  append_view_path NoNamespaceResolver.new

  def index
    @boards = Board.all(Board.writing)
    @board  = @boards.build
    enforce_view_permission(@board)
    @drafts = News.draft.sorted
    @news   = News.candidate.sorted
  end
end
