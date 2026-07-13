# encoding: UTF-8
class Moderation::NewsController < ModerationController
  before_action :find_news, except: [:index]
  after_action  :expire_cache, only: [:update, :accept]
  after_action  :marked_as_read, only: [:show, :update, :vote]
  respond_to :html, :md

  def index
    @news    = News.candidate.sorted
    @drafts  = News.draft.sorted
    @refused = News.refused.order("updated_at DESC").limit(15)
    @polls   = Poll.draft
    @boards  = Board.all(Board.amr)
  end

  def show
    enforce_view_permission(@news)
    path = moderation_news_path(@news, format: params[:format])
    redirect_to path, status: 301 and return if request.path != path
    @boards = Board.all(Board.news, @news.id)
    headers["Cache-Control"] = "no-cache, no-store, must-revalidate, max-age=0"
    flash.now[:alert] = "Attention, cette dépêche a été supprimée et n’est visible que par l’équipe de modération" if @news.deleted?
    flash.now[:alert] = "Attention, cette dépêche a été refusée et n’est visible que par l’équipe de modération" if @news.refused?
    respond_to do |wants|
      wants.html { render :show, layout: 'chat_n_edit' }
      wants.js { render partial: 'redaction/news/short' }
      wants.md { @news.put_paragraphs_together }
    end
  end

  def edit
    enforce_update_permission(@news)
    render partial: 'form'
  end

  def update
    enforce_update_permission(@news)
    @news.attributes = news_params
    @news.editor = current_account
    @news.save
    if request.xhr?
      render partial: 'redaction/news/short'
    else
      redirect_to @news, notice: "Modification enregistrée"
    end
  end

  def accept
    enforce_accept_permission(@news)
    if @news.has_default_paragraph?
      redirect_to [:moderation, @news], alert: "Impossible de publier une dépêche avec le texte par défaut d’un paragraphe"
    elsif @news.unlocked?
      @news.moderator_id = current_user.id
      @news.accept!
      @news.no_more_urgent!
      NewsNotifications.accept(@news).deliver_now
      redirect_to @news, alert: "Dépêche acceptée"
    else
      redirect_to [:moderation, @news], alert: "Impossible de modérer la dépêche tant que quelqu’un est en train de la modifier"
    end
  end

  def refuse
    enforce_refuse_permission(@news)
    if params[:message]
      @news.moderator_id = current_user.id
      @news.put_paragraphs_together
      @news.refuse!
      @news.no_more_urgent!
      notif = NewsNotifications.refuse_with_message(@news, params[:message], params[:template])
      notif.deliver_now if notif
      Board.amr_notification("La dépêche #{news_url(@news)} a été refusée par #{current_user.name} #{user_url(current_user)}")
      redirect_to '/'
    elsif @news.unlocked?
      @boards = Board.all(Board.news, @news.id)
    else
      redirect_to [:moderation, @news], alert: "Impossible de modérer la dépêche tant que quelqu’un est train de la modifier"
    end
  end

  def rewrite
    enforce_rewrite_permission(@news)
    if @news.unlocked?
      @news.moderator_id = current_user.id
      @news.rewrite!
      NewsNotifications.rewrite(@news).deliver_now
      redirect_to @news, alert: "Dépêche renvoyée en rédaction"
    else
      redirect_to [:moderation, @news], alert: "Impossible de modérer la dépêche tant que quelqu’un est en train de la modifier"
    end
  end

  def reset
    enforce_reset_permission(@news)
    @news.reset_votes
    Board.amr_notification("Sur la dépêche #{news_url(@news)} les votes ont été remis à zéro par #{current_user.name} #{user_url(current_user)}")
    redirect_to [:moderation, @news], notice: "Votes remis à zéro"
  end

  def ppp
    enforce_ppp_permission(@news)
    @news.set_on_ppp
    Board.amr_notification("La dépêche #{news_url(@news)} a été mise à la une par #{current_user.name} #{user_url(current_user)}")
    redirect_to [:moderation, @news], notice: "Cette dépêche est maintenant affichée en phare"
  end

  def vote
    render partial: "vote"
  end

protected

  def news_params
    params.require(:news).permit(:title, :section_id, :wiki_body, :wiki_second_part, :body, :second_part,
                                 links_attributes: [Link::Accessible])
  end

  def find_news
    @news = News.find(params[:id])
  end

  def marked_as_read
    current_account.read(@news.node) unless params[:format] == "md"
  end

  def expire_cache
    return if @news.state == "candidate"
    expire_page controller: '/news', action: :index, format: :atom
  end
end
