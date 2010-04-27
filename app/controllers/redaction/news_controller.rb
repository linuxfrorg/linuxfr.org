class Redaction::NewsController < RedactionController
  before_filter :load_news, :except => [:index, :create]

  def index
    @news = News.draft.sorted
  end

  def create
    @news = News.create_for_redaction(current_user)
    redirect_to [:redaction, @news]
  end

  def show
    @boards = @news.boards
    respond_to do |wants|
      wants.html {
        redirect_to [:redaction, @news], :status => 301 and return if !@news.friendly_id_status.best?
        render :show, :layout => 'chat_n_edit'
      }
      wants.js { render :partial => 'short' }
    end
  end

  def edit
    respond_to do |wants|
      wants.js { render :partial => 'form' }
    end
  end

  def update
    @news.attributes = params[:news]
    @news.editor_id = current_user.id
    @news.save
    respond_to do |wants|
      wants.js { render :nothing => true }
    end
  end

  def submit
    if @news.unlocked?
      @news.submit_and_notify(current_user.id)
      redirect_to '/redaction', :notice => "Dépêche soumis à la modération"
    else
      redirect_to [:redaction, @news], :alert => "Impossible de soumettre la dépêche car quelqu'un est encore en train de la modifier"
    end
  end

protected

  def load_news
    @news = News.find(params[:id])
    enforce_update_permission(@news)
  end

end
