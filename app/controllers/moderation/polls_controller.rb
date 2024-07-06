# encoding: UTF-8
class Moderation::PollsController < ModerationController
  before_action :find_poll, except: [:index]
  after_action  :expire_cache, only: [:update, :accept]

  def index
    @polls = Poll.draft.order("id DESC")
  end

  def show
    enforce_view_permission(@poll)
    flash.now[:alert] = "Attention, ce sondage a été supprimé et n’est visible que par l’équipe de modération" if @poll.deleted?
    flash.now[:alert] = "Attention, ce sondage a été refusé et n’est visible que par l’équipe de modération" if @poll.refused?
  end

  def accept
    enforce_accept_permission(@poll)
    @poll.accept!
    Board.amr_notification("Le sondage #{poll_url @poll} a été accepté par #{current_user.name} #{user_url(current_user)}")
    redirect_to @poll, notice: "Sondage accepté"
  end

  def refuse
    enforce_refuse_permission(@poll)
    @poll.refuse!
    Board.amr_notification("Le sondage #{poll_url @poll} a été refusé par #{current_user.name} #{user_url(current_user)}")
    redirect_to moderation_polls_url, notice: "Sondage refusé"
  end

  def edit
    enforce_update_permission(@poll)
  end

  def update
    enforce_update_permission(@poll)
    @poll.attributes = poll_params
    if @poll.save
      redirect_to [:moderation, @poll], notice: "Modification enregistrée"
    else
      flash.now[:alert] = "Impossible d’enregistrer ce sondage"
      render :edit
    end
  end

  def ppp
    enforce_accept_permission(@poll)
    @poll.set_on_ppp
    Board.amr_notification("Le sondage #{poll_url @poll} a été mis en une par #{current_user.name} #{user_url(current_user)}")
    redirect_to root_url, notice: "Le sondage a bien été mis en phare"
  end

protected

  def poll_params
    params.require(:poll).permit!
  end

  def find_poll
    @poll = Poll.find(params[:id])
  end

  def expire_cache
    return if @poll.state == "draft"
    expire_page controller: '/polls', action: :index, format: :atom
  end
end
