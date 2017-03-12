# encoding: utf-8
class RedactionController < ApplicationController
  append_view_path NoNamespaceResolver.new

  def index
    @boards = Board.limit(25, Board.writing)
    @drafts = News.draft.sorted
    @news   = News.candidate.sorted
    @stats  = Statistics::Redaction.new
  end
end
