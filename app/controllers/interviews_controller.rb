class InterviewsController < ApplicationController
  before_filter :user_required, :except => [:index, :show, :comments]
  after_filter  :marked_as_read, :only => [:show]

  def index
    @interviews = Interview.public.sorted
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def comments
    @comments = Comment.published.scoped_by_content_type('Interview').all(:limit => 20)
    @title    = "les propositions d'entretien"
    respond_to do |wants|
      wants.atom { render 'comments/index' }
    end
  end

  def show
    @interview = Interview.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @interview && @interview.readable_by?(current_user)
  end

  def new
    @preview_mode = false
    @interview = Interview.new
    raise ActiveRecord::RecordNotFound.new unless @interview && @interview.creatable_by?(current_user)
  end

  def create
    @interview = Interview.new
    raise ActiveRecord::RecordNotFound.new unless @interview && @interview.creatable_by?(current_user)
    @interview.attributes = params[:interview]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @interview.save
      @interview.node = Node.create(:public => false, :user_id => current_user.id)
      flash[:success] = "Nous vous remercions pour avoir proposé un entretien. Cette proposition va être examinée par l'équipe de modération."
      redirect_to interviews_url
    else
      @interview.node = Node.new
      render :new
    end
  end

protected

  def marked_as_read
    current_user.read(@interview.node) if current_user
  end

end
