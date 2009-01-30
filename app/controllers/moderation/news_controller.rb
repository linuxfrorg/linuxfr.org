class Moderation::NewsController < ModerationController

  def index
    @news = News.draft.sorted
  end

  def show
    @news = News.find(params[:id])
  end

end
