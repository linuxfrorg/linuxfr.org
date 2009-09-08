class TrackersController < ApplicationController
  before_filter :user_required, :except => [:index, :show, :comments]
  after_filter  :marked_as_read, :only => [:show]

  def index
    @trackers = Tracker.sorted.open
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def comments
    @comments = Comment.published.scoped_by_content_type('Tracker').all(:limit => 20)
    @title    = 'le tracker'
    respond_to do |wants|
      wants.atom { render 'comments/index' }
    end
  end

  def show
    @tracker = Tracker.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @tracker && @tracker.readable_by?(current_user)
  end

  def new
    @preview_mode = false
    @tracker = Tracker.new
    raise ActiveRecord::RecordNotFound.new unless @tracker && @tracker.creatable_by?(current_user)
  end

  def create
    @tracker = Tracker.new
    raise ActiveRecord::RecordNotFound.new unless @tracker && @tracker.creatable_by?(current_user)
    @tracker.attributes = params[:tracker]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @tracker.save
      @tracker.node = Node.create(:user_id => current_user.id)
      flash[:success] = "Votre entrée a bien été créée dans le suivi"
      redirect_to trackers_url
    else
      @tracker.node = Node.new
      render :new
    end
  end

  def edit
    @tracker = Tracker.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @tracker && @tracker.editable_by?(current_user)
  end

  def update
    @tracker = Tracker.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @tracker && @tracker.editable_by?(current_user)
    @tracker.attributes = params[:tracker]
    @tracker.assigned_to_user = current_user
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @tracker.save
      flash[:success] = "Entrée du suivi modifiée"
      redirect_to trackers_url
    else
      render :edit
    end
  end

  def destroy
    @tracker = Tracker.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @tracker && @tracker.deletable_by?(current_user)
    @tracker.mark_as_deleted
    flash[:success] = "Entrée du suivi supprimée"
    redirect_to trackers_url
  end

protected

  def marked_as_read
    current_user.read(@tracker.node) if current_user
  end

end
