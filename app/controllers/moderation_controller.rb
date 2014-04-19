# encoding: utf-8
class ModerationController < ApplicationController
  before_action :amr_required
  append_view_path RedactionResolver.new
  append_view_path NoNamespaceResolver.new

  def index
    redirect_to moderation_news_index_url
  end
end
