# encoding: UTF-8
class Redaction::NewsController < RedactionController
  before_filter :load_news, :except => [:index, :create]

  def index
    @news = News.draft.sorted
  end

  def create
    @news = News.create_for_redaction(current_account)
    redirect_to [:redaction, @news]
  end

  def show
    @boards = Board.all(Board.news, @news.id)
    redirect_to [:redaction, @news], :status => 301 and return if !@news.friendly_id_status.best?
    render :show, :layout => 'chat_n_edit'
  end

  def revision
    @version  = @news.versions.find_by_version!(params[:revision])
    @previous = @version.higher_item || NewsVersion.new
  end

  def edit
    render :partial => 'form'
  end

  def update
    @news.attributes = params[:news]
    @news.editor = current_account
    @news.save
    render :partial => 'short'
  end

  def submit
    if @news.unlocked?
      @news.submit_and_notify(current_user)
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
