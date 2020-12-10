# encoding: utf-8
class RedactionController < ApplicationController
  append_view_path NoNamespaceResolver.new

  def index
    activity_threshold = Date.today - 3.month
    @boards = Board.limit(25, Board.writing)
    @drafts = News.draft.where("updated_at >= ?", activity_threshold).sorted
    @inactive_drafts = News.draft.where("updated_at < ?", activity_threshold).sorted
    @news   = News.candidate.sorted
    @stats  = Statistics::Redaction.new
  end
end
