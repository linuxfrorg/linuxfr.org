# encoding: UTF-8
class TrackersController < ApplicationController
  before_action :honeypot, only: [:create]
  before_action :authenticate_account!, only: [:edit, :update, :destroy]
  before_action :load_tracker, only: [:show, :edit, :update, :destroy]
  after_action  :marked_as_read, only: [:show], if: :account_signed_in?
  respond_to :html, :md

  def index
    extracted = params.extract!(:tracker).permit(tracker: [:state, :category_id, :assigned_to_user_id])
    @attrs    = { "state" => "opened" }.merge(extracted[:tracker] || {})
    @order    = params[:order]
    @order    = "created_at" unless VALID_ORDERS.include?(@order)
    @trackers = Tracker.joins(:node).merge(Node.visible)
    if @order == "created_at"
      @trackers = @trackers.order("#{@order} DESC")
    else
      @trackers = @trackers.order("nodes.#{@order} DESC")
    end
    @tracker  = Tracker.new(@attrs.except("state"))
    @tracker.state = @attrs["state"]
    @trackers = @trackers.where(state: @tracker.state)             if @attrs["state"].present?
    @trackers = @trackers.where(category_id: @tracker.category_id) if @attrs["category_id"].present?
    if @attrs["assigned_to_user_id"] == "0"
      @trackers = @trackers.where(assigned_to_user_id: nil)
    elsif @attrs["assigned_to_user_id"].present?
      @trackers = @trackers.where(assigned_to_user_id: @tracker.assigned_to_user_id)
    end
    respond_to do |wants|
      wants.html { @trackers = @trackers.page(params[:page]).per(100) }
      wants.atom
    end
  end

  def comments
    @comments = Comment.published.joins(:node).where('nodes.content_type' => 'Tracker').order('created_at DESC').limit(20)
    respond_to do |wants|
      wants.atom
    end
  end

  def show
    enforce_view_permission(@tracker)
    path = tracker_path(@tracker, format: params[:format])
    headers['Link'] = %(<#{tracker_url @tracker}>; rel="canonical")
    redirect_to path, status: 301 if request.path != path
  end

  def new
    @tracker = Tracker.new
  end

  def create
    @tracker = Tracker.new tracker_params
    @tracker.tmp_owner_id = current_user.try(:id)
    if !preview_mode && @tracker.save
      redirect_to @tracker, notice: "Votre entrée a bien été créée dans le suivi"
    else
      @tracker.node = Node.new
      @tracker.valid?
      render :new
    end
  end

  def edit
    enforce_update_permission(@tracker)
    @tracker.assigned_to_user ||= current_user
  end

  def update
    enforce_update_permission(@tracker)
    @tracker.attributes = tracker_params
    if !preview_mode && @tracker.save
      redirect_to @tracker, notice: "Entrée du suivi modifiée"
    else
      flash.now[:alert] = "Impossible d’enregistrer cette entrée de suivi" unless @tracker.valid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@tracker)
    @tracker.mark_as_deleted
    Board.amr_notification("L’entrée de suivi #{tracker_url @tracker} a été supprimée par #{current_user.name} #{user_url(current_user)}")
    redirect_to trackers_url, notice: "Entrée du suivi supprimée"
  end

protected

  def tracker_params
    if current_account.try(:tracker_admin?)
      params.require(:tracker).permit!
    else
      params.require(:tracker).permit(:title, :wiki_body, :category_id, :state)
    end
  end

  def honeypot
    honeypot = params[:tracker].delete(:pot_de_miel)
    head :no_content if honeypot.present?
  end

  def marked_as_read
    current_account.read(@tracker.node) unless params[:format] == "md"
  end

  def load_tracker
    @tracker = Tracker.find(params[:id])
  end
end
