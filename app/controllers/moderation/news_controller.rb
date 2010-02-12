class Moderation::NewsController < ModerationController
  before_filter :find_news, :except => [:index]

  def index
    @news  = News.candidate.sorted
    @polls = Poll.draft
  end

  def show
    @boards = @news.boards
    respond_to do |wants|
      wants.html {
        redirect_to [:moderation, @news], :status => 301 and return if @news.has_better_id?
        render :show, :layout => 'chat_n_edit'
      }
      wants.js { render :partial => 'short' }
    end
  end

  def edit
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    respond_to do |wants|
      wants.js { render :partial => 'form' }
    end
  end

  def update
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    @news.attributes = params[:news]
    @news.editor_id = current_user.id
    @news.save
    respond_to do |wants|
      wants.js { render :nothing => true }
    end
  end

  def accept
    raise ActiveRecord::RecordNotFound unless @news && @news.acceptable_by?(current_user)
    if @news.unlocked?
      @news.moderator_id = current_user.id
      @news.accept!
      NewsNotifications.accept(@news).deliver
      redirect_to @news, :alert => "Dépêche acceptée"
    else
      redirect_to [:moderation, @news], :alert => "Impossible de modérer la dépêche tant que quelqu'un est en train de la modifier"
    end
  end

  def refuse
    raise ActiveRecord::RecordNotFound unless @news && @news.refusable_by?(current_user)
    if params[:message]
      @news.refuse!
      notif = NewsNotifications.refuse_with_message(@news, params[:message], params[:template])
      notif.deliver if notif
      redirect_to @news
    elsif @news.unlocked?
      @boards = @news.boards
    else
      redirect_to [:moderation, @news], :alert => "Impossible de modérer la dépêche tant que quelqu'un est train de la modifier"
    end
  end

  def ppp
    raise ActiveRecord::RecordNotFound unless @news && @news.pppable_by?(current_user)
    @news.set_on_ppp
    redirect_to @news
  end

  # TODO to be removed?
  def show_diff
    raise ActiveRecord::RecordNotFound unless @news
    @commit = Commit.new(@news, params[:sha])
  end

  def clear_locks
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    @news.clear_locks(current_user)
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js   { render :nothing => true }
    end
  end

protected

  def find_news
    @news = News.find(params[:id])
  end

end
