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
    redirect_to @tracker, :status => 301 if @tracker.has_better_id?
  end

  def new
    @tracker = Tracker.new
    raise ActiveRecord::RecordNotFound.new unless @tracker && @tracker.creatable_by?(current_user)
  end

  def create
    @tracker = Tracker.new
    raise ActiveRecord::RecordNotFound.new unless @tracker && @tracker.creatable_by?(current_user)
    @tracker.attributes = params[:tracker]
    if !preview_mode && @tracker.save
      @tracker.create_node(:user_id => current_user.id)
      redirect_to trackers_url, :notice => "Votre entrée a bien été créée dans le suivi"
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
    if !preview_mode && @tracker.save
      redirect_to trackers_url, :notice => "Entrée du suivi modifiée"
    else
      render :edit
    end
  end

  def destroy
    @tracker = Tracker.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @tracker && @tracker.deletable_by?(current_user)
    @tracker.mark_as_deleted
    redirect_to trackers_url, :notice => "Entrée du suivi supprimée"
  end

protected

  def marked_as_read
    current_user.read(@tracker.node) if current_user
  end

end
