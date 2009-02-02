class Moderation::NewsController < ModerationController

  def index
    @news = News.draft.sorted
  end

  def show
    @news = News.find(params[:id])
  end

  def accept
    @news = News.find(params[:id])
    raise ActiveRecord::NotFound unless @news && @news.acceptable_by?(current_user)
    @news.accept!
    redirect_to @news
  end

  def refuse
    @news = News.find(params[:id])
    raise ActiveRecord::NotFound unless @news && @news.refusable_by?(current_user)
    @news.refuse!
    redirect_to @news
  end

  def edit
    @news = News.find(params[:id])
    raise ActiveRecord::NotFound unless @news && @news.editable_by?(current_user)
  end

  def update
    @news = News.find(params[:id])
    raise ActiveRecord::NotFound unless @news && @news.editable_by?(current_user)
    @news.attributes = params[:news]
    @news.committer  = current_user
    if @news.save
      flash[:success] = "Modification enregistrée"
      redirect_to [:moderation, @news]
    else
      render :edit
    end
  end

end
