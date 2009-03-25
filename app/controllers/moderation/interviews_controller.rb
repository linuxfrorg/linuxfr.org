class Moderation::InterviewsController < ModerationController

  def index
    @drafts    = Interview.draft
    @open_itws = Interview.open
    @sent_itws = Interview.sent
  end

  def show
    @interview = Interview.find(params[:id])
  end

  def accept
    @interview = Interview.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @interview && @interview.acceptable_by?(current_user)
    @interview.accept!
    redirect_to @interview
  end

  def refuse
    @interview = Interview.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @interview && @interview.refusable_by?(current_user)
    @interview.refuse!
    redirect_to moderation_interviews_url
  end

  def contact
    @interview = Interview.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @interview
    @interview.assigned_to_user_id = current_user.id
    @interview.contact!
    redirect_to moderation_interviews_url
  end

  def publish
    @interview = Interview.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @interview
    @interview.news_id = params[:news_id]
    @interview.publish! unless @interview.published?
    redirect_to @interview
  end

  def edit
    @interview = Interview.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @interview && @interview.editable_by?(current_user)
  end

  def update
    @interview = Interview.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @interview && @interview.editable_by?(current_user)
    @interview.attributes = params[:interview]
    if @interview.save
      flash[:success] = "Modification enregistrée"
      redirect_to [:moderation, @interview]
    else
      render :edit
    end
  end

end
