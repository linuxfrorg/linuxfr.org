# encoding: UTF-8
class PollsController < ApplicationController
  before_filter :authenticate_account!, :only => [:new, :create]
  before_filter :find_poll, :only => [:show, :vote]
  after_filter  :marked_as_read, :only => [:show], :if => :account_signed_in?
  caches_page   :index, :if => Proc.new { |c| c.request.format.atom? && !c.request.ssl? }
  respond_to :html, :atom

  def index
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
    @polls = Poll.archived.joins(:node).order("nodes.#{@order} DESC").page(params[:page])
    if on_the_first_page?
      poll = Poll.current
      @polls.unshift(poll) if poll
    end
    respond_with(@polls)
  end

  def show
    enforce_view_permission(@poll)
    @poll.state = 'archived' if params.has_key? :results
    redirect_to @poll, :status => 301 if !@poll.friendly_id_status.best?
  end

  def new
    @poll = Poll.new
    enforce_create_permission(@poll)
  end

  def create
    @poll = Poll.new
    enforce_create_permission(@poll)
    @poll.attributes = params[:poll]
    @poll.owner_id = current_account.user_id
    if !preview_mode && @poll.save
      redirect_to polls_url, :notice => "L'équipe de modération de LinuxFr.org vous remercie pour votre proposition de sondage"
    else
      @poll.node = Node.new
      @poll.valid?
      render :new
    end
  end

  def vote
    enforce_answer_permission(@poll)
    @answer = @poll.answers.where(:position => params[:position]).first
    if @answer
      @answer.vote(request.remote_ip)
      redirect_to @poll, :notice => "Merci d'avoir voté pour ce sondage"
    else
      redirect_to @poll, :alert => "Veuillez choisir une proposition avant de voter"
    end
  end

protected

  def on_the_first_page?
    params[:page].to_i <= 1
  end

  def find_poll
    @poll = Poll.find(params[:id])
  end

  def marked_as_read
    current_account.read(@poll.node)
  end

  def enforce_answer_permission(poll)
    raise Canable::Transgression unless poll.answerable_by?(request.remote_ip)
  end
end
