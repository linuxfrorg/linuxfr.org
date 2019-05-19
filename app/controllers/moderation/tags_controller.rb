# encoding: UTF-8
class Moderation::TagsController < ModerationController

  def index
    @tags = Tag.public_tags
  end
end
