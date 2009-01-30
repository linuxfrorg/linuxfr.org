class ModerationController < ApplicationController
  before_filter :login_required
  # TODO only allows amr in the moderation backend

  def index
    redirect_to moderation_news_index_url
  end
end
