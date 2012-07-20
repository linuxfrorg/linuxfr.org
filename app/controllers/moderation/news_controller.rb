# encoding: UTF-8
class Moderation::NewsController < ModerationController
  before_filter :find_news, :except => [:index]
  after_filter  :expire_cache, :only => [:update, :accept]
  after_filter  :marked_as_read, :only => [:show, :update, :vote]

  def index
    @news    = News.candidate.sorted
    @drafts  = News.draft.sorted
    @refused = News.refused.sorted.limit(15)
    @polls   = Poll.draft
    @boards  = Board.all(Board.amr)
  end

  def show
    enforce_view_permission(@news)
    @boards = Board.all(Board.news, @news.id)
    respond_to do |wants|
      wants.html {
        path = moderation_news_path(@news)
        redirect_to path, :status => 301 and return if request.path != path
        render :show, :layout => 'chat_n_edit'
      }
      wants.js { render :partial => 'short' }
    end
  end

  def edit
    enforce_update_permission(@news)
    render :partial => 'form'
  end

  def update
    enforce_update_permission(@news)
    @news.body = params[:news].delete(:body) if params[:news].has_key?(:body)
    @news.second_part = params[:news].delete(:second_part) if params[:news].has_key?(:second_part)
    @news.attributes = params[:news]
    @news.editor = current_account
    @news.save
    if request.xhr?
      render :partial => 'short'
    else
      redirect_to @news, :notice => "Modification enregistrée"
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
      @news.moderator_id = current_user.id
      @news.put_paragraphs_together
      @news.refuse!
      notif = NewsNotifications.refuse_with_message(@news, params[:message], params[:template])
      notif.deliver if notif
      redirect_to '/'
    elsif @news.unlocked?
      @boards = Board.all(Board.news, @news.id)
    else
      redirect_to [:moderation, @news], :alert => "Impossible de modérer la dépêche tant que quelqu'un est train de la modifier"
    end
  end

  def reset
    enforce_reset_permission(@news)
    @news.reset_votes
    redirect_to [:moderation, @news], :notice => "Votes remis à zéro"
  end

  def rewrite
    enforce_rewrite_permission(@news)
    if @news.unlocked?
      @news.moderator_id = current_user.id
      @news.rewrite!
      NewsNotifications.rewrite(@news).deliver
      redirect_to @news, :alert => "Dépêche renvoyée en rédaction"
    else
      redirect_to [:moderation, @news], :alert => "Impossible de modérer la dépêche tant que quelqu'un est en train de la modifier"
    end
  end

  def ppp
    enforce_ppp_permission(@news)
    @news.set_on_ppp
    redirect_to [:moderation, @news], :notice => "Cette dépêche est maintenant affichée en phare"
  end

  def vote
    render :partial => "vote"
  end

protected

  def find_news
    @news = News.find(params[:id])
  end

  def marked_as_read
    current_account.read(@news.node)
  end

  def expire_cache
    return if @news.state == "candidate"
    expire_page :controller => '/news', :action => :index, :format => :atom
    expire_action :controller => '/news', :action => :show, :id => @news.to_param
  end

end
