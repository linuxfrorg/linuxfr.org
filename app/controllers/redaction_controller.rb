# encoding: utf-8
class RedactionController < ApplicationController
  before_filter :authenticate_account!
  append_view_path NoNamespaceResolver.new

  def index
    @boards = Board.all(Board.writing)
    @board  = @boards.build
    @drafts = News.draft.sorted
    @news   = News.candidate.sorted
    @stats  = Statistics::Redaction.new
  end
end
