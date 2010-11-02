# encoding: UTF-8
class Moderation::NewsController < ModerationController
  before_filter :find_news, :except => [:index]
  after_filter  :expire_cache, :only => [:create, :update, :destroy]

  def index
    @news  = News.candidate.sorted
    @polls = Poll.draft
  end

  def show
    enforce_view_permission(@news)
    @boards = Board.all(Board.news, @news.id)
    respond_to do |wants|
      wants.html {
        redirect_to [:moderation, @news], :status => 301 and return if !@news.friendly_id_status.best?
        render :show, :layout => 'chat_n_edit'
      }
      wants.js { render :partial => 'short' }
    end
  end

  def edit
    enforce_update_permission(@news)
    respond_to do |wants|
      wants.js { render :partial => 'form' }
    end
  end

  def update
    enforce_update_permission(@news)
    @news.attributes = params[:news]
    @news.editor = current_user
    @news.save
    respond_to do |wants|
      wants.js { render :nothing => true }
    end
  end

  def accept
    enforce_accept_permission(@news)
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
    enforce_refuse_permission(@news)
    if params[:message]
      @news.refuse!
      notif = NewsNotifications.refuse_with_message(@news, params[:message], params[:template])
      notif.deliver if notif
      redirect_to @news
    elsif @news.unlocked?
      @boards = Board.all(Board.news, @news.id)
    else
      redirect_to [:moderation, @news], :alert => "Impossible de modérer la dépêche tant que quelqu'un est train de la modifier"
    end
  end

  def ppp
    enforce_ppp_permission(@news)
    @news.set_on_ppp
    redirect_to [:moderation, @news], :notice => "Cette dépêche est maintenant affichée en phare"
  end

  def clear_locks
    enforce_update_permission(@news)
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

  def expire_cache
    expire_page :controller => :news, :action => :index, :format => :atom
    expire_action :controller => :news, :action => :show, :id => @news unless @news.new_record?
  end
end
