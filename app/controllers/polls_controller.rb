# encoding: UTF-8
class PollsController < ApplicationController
  skip_before_action :verify_authenticity_token , only: [:vote]
  before_action :verify_referer_or_authenticity_token, only: [:vote]
  before_action :authenticate_account!, only: [:new, :create]
  before_action :find_poll, only: [:show, :vote]
  after_action  :marked_as_read, only: [:show], if: :account_signed_in?
  caches_page   :index, if: Proc.new { |c| c.request.format.atom? && !c.request.ssl? }
  respond_to :html, :atom, :md

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
    redirect_to [:moderation, @poll] unless @poll.published?
    @poll.state = 'archived' if params.has_key? :results
    path = poll_path(@poll, format: params[:format])
    headers['Link'] = %(<#{poll_url @poll}>; rel="canonical")
    redirect_to path, status: 301 and return if request.path != path
  end

  def new
    @poll = Poll.new
    enforce_create_permission(@poll)
  end

  def create
    @poll = Poll.new
    enforce_create_permission(@poll)
    @poll.attributes = poll_params
    @poll.tmp_owner_id = current_account.user_id
    if !preview_mode && @poll.save
      redirect_to polls_url, notice: "L'équipe de modération de LinuxFr.org vous remercie pour votre proposition de sondage"
    else
      @poll.node = Node.new
      @poll.valid?
      render :new
    end
  end

  def vote
    enforce_answer_permission(@poll)
    @answer = @poll.answers.where(position: params[:position]).first
    if @answer
      @answer.vote(request.remote_ip)
      redirect_to @poll, notice: "Merci d'avoir voté pour ce sondage"
    else
      redirect_to @poll, alert: "Veuillez choisir une proposition avant de voter"
    end
  end

protected

  def poll_params
    params.require(:poll).permit(:title, :wiki_explanations, :cc_licensed,
                                 answers_attributes: [:answer])
  end

  def on_the_first_page?
    params[:page].to_i <= 1
  end

  def find_poll
    @poll = Poll.find(params[:id])
  end

  def marked_as_read
    current_account.read(@poll.node) unless params[:format] == "md"
  end

  def enforce_answer_permission(poll)
    raise Canable::Transgression unless poll.answerable_by?(request.remote_ip)
  end
end
