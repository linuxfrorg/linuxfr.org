class RedactionController < ApplicationController
  before_filter :writer_required

  def index
    redirect_to redaction_news_index_url
  end
end
