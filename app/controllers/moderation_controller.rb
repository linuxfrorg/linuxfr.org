# encoding: utf-8
class ModerationController < ApplicationController
  before_action :amr_required

  def index
    redirect_to moderation_news_index_url
  end
end
