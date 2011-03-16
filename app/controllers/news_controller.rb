# encoding: UTF-8
class NewsController < ApplicationController
  before_filter :honeypot, :only => [:create]
  before_filter :find_news, :only => [:show, :anonymous]
  after_filter  :marked_as_read, :only => [:show], :if => :account_signed_in?
  caches_page :index, :if => Proc.new { |c| c.request.format.atom? && !c.request.ssl? }
  caches_action :show, :unless => :account_signed_in?, :expires_in => 5.minutes
  respond_to :html, :atom

  def index
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
    @nodes = Node.public_listing(News, @order).page(params[:page])
    respond_with(@nodes)
  end

  def calendar
    @year  = params[:year].to_i
    @month = params[:month].to_i
    @day   = params[:day].to_i
    @nodes = Node.public_listing(News, "created_at").published_on(Date.new(@year, @month, @day)).page(params[:page])
  end

  def show
    redirect_to [:redaction, @news] if @news.draft?
  end

  def new
    @news = News.new
  end

  def create
    @news = News.new
    @news.attributes   = params[:news]
    @news.author_name  = current_account.name  if current_account
    @news.author_email = current_account.email if current_account
    if !preview_mode && @news.save
      @news.submit!
      redirect_to news_index_url, :notice => "Votre proposition de dépêche a bien été soumise, et sera modérée dans les heures ou jours à venir"
    else
      @news.node = Node.new
      @news.valid?
      render :new
    end
  end

protected

  def honeypot
    honeypot = params[:news].delete(:pot_de_miel)
    render :nothing => true if honeypot.present?
  end

  def find_news
    @news = News.find(params[:id])
    enforce_view_permission(@news)
    redirect_to @news, :status => 301 if !@news.friendly_id_status.best?
  end

  def marked_as_read
    current_account.read(@news.node)
  end

end
