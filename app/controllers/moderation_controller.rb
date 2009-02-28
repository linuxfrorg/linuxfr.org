class ModerationController < ApplicationController
  before_filter :amr_required

  def index
    redirect_to moderation_news_index_url
  end
end
