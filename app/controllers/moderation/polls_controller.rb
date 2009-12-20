class Moderation::PollsController < ModerationController

  def index
    @polls = Poll.draft
  end

  def show
    @poll = Poll.find(params[:id])
  end

  def accept
    @poll = Poll.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @poll && @poll.acceptable_by?(current_user)
    @poll.accept!
    redirect_to @poll, :notice => "Sondage accepté"
  end

  def refuse
    @poll = Poll.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @poll && @poll.refusable_by?(current_user)
    @poll.refuse!
    redirect_to moderation_polls_url, :notice => "Sondage refusé"
  end

  def edit
    @poll = Poll.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @poll && @poll.editable_by?(current_user)
  end

  def update
    @poll = Poll.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @poll && @poll.editable_by?(current_user)
    @poll.attributes = params[:poll]
    if @poll.save
      redirect_to [:moderation, @poll], :notice => "Modification enregistrée"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce sondage"
      render :edit
    end
  end

end
