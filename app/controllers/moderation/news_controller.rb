class Moderation::NewsController < ModerationController

  def index
    @news  = News.candidate.sorted
    @polls = Poll.draft
    @interviews = Interview.draft
  end

  def show
    @news   = News.find(params[:id])
    @boards = @news.boards
    render :show, :layout => 'redaction'
  end

  def accept
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.acceptable_by?(current_user)
    @news.moderator_id = current_user.id
    @news.accept!
    @news.boards.moderation.create(:message => "<b>Dépêche acceptée</b>", :user_agent => request.user_agent, :user_id => current_user.id)
    NewsNotifications.deliver_accept(@news)
    redirect_to @news
  end

  def refuse
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.refusable_by?(current_user)
    if params[:message]
      @news.refuse!
      @news.boards.moderation.create(:message => "<b>Dépêche refusée</b>", :user_agent => request.user_agent, :user_id => current_user.id)
      if params[:template]
        NewsNotifications.deliver_refuse_template(@news, params[:message], params[:template])
      elsif params[:message] == 'en'
        NewsNotifications.deliver_refuse_en(@news)
      elsif params[:message].present?
        NewsNotifications.deliver_refuse(@news, params[:message])
      end
      redirect_to @news
    else
      @boards = @news.boards
    end
  end

  def ppp
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.pppable_by?(current_user)
    @news.set_on_ppp
    redirect_to @news
  end

  def edit
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
  end

  def update
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    @news.attributes = params[:news]
    @news.committer  = current_user
    if @news.save
      flash[:success] = "Modification enregistrée"
      redirect_to [:moderation, @news]
    else
      render :edit
    end
  end

  def show_diff
    @news = News.find(params[:news_id])
    raise ActiveRecord::RecordNotFound unless @news
    @commit = Commit.new(@news, params[:sha])
  end

end
