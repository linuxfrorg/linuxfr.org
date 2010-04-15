class TrackersController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show, :comments]
  before_filter :load_tracker, :only => [:show, :edit, :update, :destroy]
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
    enforce_view_permission(@tracker)
    redirect_to @tracker, :status => 301 if !@tracker.friendly_id_status.best?
  end

  def new
    @tracker = Tracker.new
    enforce_create_permission(@tracker)
  end

  def create
    @tracker = Tracker.new
    enforce_create_permission(@tracker)
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
    enforce_update_permission(@tracker)
  end

  def update
    enforce_update_permission(@tracker)
    @tracker.attributes = params[:tracker]
    @tracker.assigned_to_user = current_user
    if !preview_mode && @tracker.save
      redirect_to trackers_url, :notice => "Entrée du suivi modifiée"
    else
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@tracker)
    @tracker.mark_as_deleted
    redirect_to trackers_url, :notice => "Entrée du suivi supprimée"
  end

protected

  def marked_as_read
    current_user.read(@tracker.node) if current_user
  end

  def load_tracker
    @tracker = Tracker.find(params[:id])
  end

end
