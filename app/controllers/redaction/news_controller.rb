# encoding: UTF-8
class Redaction::NewsController < RedactionController
  skip_before_filter :authenticate_account!, :only => [:index, :moderation]
  before_filter :load_news, :except => [:index, :moderation, :create, :revision, :reorganize, :reorganized, :reassign]
  before_filter :load_news2, :only => [:revision, :reorganize, :reorganized, :reassign]
  before_filter :load_board, :only => [:show, :reorganize]
  after_filter  :marked_as_read, :only => [:show, :update]
  respond_to :html, :atom

  def index
    @news = News.draft.sorted
    respond_with @news
  end

  def moderation
    @news = News.candidate.sorted
    respond_with @news
  end

  def create
    @news = News.create_for_redaction(current_account)
    path = redaction_news_path(@news)
    redirect_to path, :status => 301 if request.path != path
  end

  def show
    redirect_to [:redaction, @news], :status => 301 and return if request.path != redaction_news_path(@news)
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

  def reassign
    enforce_reassign_permission(@news)
    @news.reassign_to params[:user_id]
    namespace = @news.draft? ? :redaction : :moderation
    redirect_to [namespace, @news], :notice => "L'auteur initial de la dépêche a été changé"
  end

  def reorganize
    if @news.lock_by(current_user)
      @news.put_paragraphs_together
      render :reorganize, :layout => "chat_n_edit"
    else
      render :status => :forbidden, :text => "Désolé, un verrou a déjà été posé sur cette dépêche !"
    end
  end

  def reorganized
    @news.editor = current_account
    @news.reorganize params[:news]
    redirect_to [@news.draft? ? :redaction : :moderation, @news]
  end

  def followup
    enforce_followup_permission(@news)
    NewsNotifications.followup(@news, params[:message]).deliver
    redirect_to [:redaction, @news], :notice => "Courriel de relance envoyé"
  end

  def submit
    if @news.unlocked?
      @news.submit_and_notify(current_user)
      redirect_to '/redaction', :notice => "Dépêche soumise à la modération"
    else
      redirect_to [:redaction, @news], :alert => "Impossible de soumettre la dépêche car quelqu'un est encore en train de la modifier"
    end
  end

  def erase
    enforce_erase_permission(@news)
    @news.erase!
    redirect_to '/redaction', :notice => "Dépêche effacée"
  end

protected

  def load_news
    @news = News.draft.find(params[:id])
    enforce_update_permission(@news)
  end

  def load_news2
    @news = News.find(params[:id])
    enforce_update_permission(@news)
  end

  def load_board
    @boards = Board.all(Board.news, @news.id)
  end

  def marked_as_read
    current_account.read(@news.node)
  end

end
