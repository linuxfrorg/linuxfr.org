# encoding: UTF-8
class TrackersController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show, :comments]
  before_filter :load_tracker, :only => [:show, :edit, :update, :destroy]
  after_filter  :marked_as_read, :only => [:show], :if => :account_signed_in?

  def index
    @trackers = Tracker.sorted.opened
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def comments
    @comments = Comment.published.joins(:node).where('nodes.content_type' => 'Tracker').limit(20)
    @feed_for = 'le tracker'
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
    @tracker.owner_id = current_user.try(:id)
    if !preview_mode && @tracker.save
      redirect_to @tracker, :notice => "Votre entrée a bien été créée dans le suivi"
    else
      @tracker.node = Node.new
      render :new
    end
  end

  def edit
    enforce_update_permission(@tracker)
    @tracker.assigned_to_user = current_user
  end

  def update
    enforce_update_permission(@tracker)
    @tracker.send(:attributes=, params[:tracker], false) # Bypass the attr_accessible sanitizing
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
    current_account.read(@tracker.node)
  end

  def load_tracker
    @tracker = Tracker.find(params[:id])
  end
end
