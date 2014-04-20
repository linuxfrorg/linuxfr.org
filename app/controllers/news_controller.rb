# encoding: UTF-8
class NewsController < ApplicationController
  before_action :honeypot, only: [:create]
  before_action :find_news, only: [:show]
  after_action  :marked_as_read, only: [:show], if: :account_signed_in?
  caches_page :index, if: Proc.new { |c| c.request.format.atom? && !c.request.ssl? }
  respond_to :html, :atom, :md

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
    @news.put_paragraphs_together if params[:format] == "md"
  end

  def new
    redirect_to root_url, alert: "Désolé, il n'est pas possible de proposer une dépêche en l'absence de sections" unless Section.exists?
    @news = News.new
    @news.cc_licensed = true
  end

  def create
    @news = News.new
    @news.attributes   = news_params
    @news.author_name  = current_account.name  if current_account
    @news.author_email = current_account.email if current_account
    if !preview_mode && @news.save
      current_account.tag(@news.node, params[:tags]) if current_account
      @news.urgent! if params[:news][:urgent] == "1"
      @news.submitted_at = DateTime.now
      @news.submit!
      redirect_to news_index_url, notice: "Votre proposition de dépêche a bien été soumise, et sera modérée dans les heures ou jours à venir"
    else
      @news.node = Node.new
      @news.valid?
      render :new
    end
  end

protected

  def news_params
    params.require(:news).permit(:title, :section_id, :author_name, :author_email,
                                 :message, :wiki_body, :wiki_second_part, :urgent,
                                 links_attributes: [Link::Accessible])
  end

  def honeypot
    honeypot = params[:news].delete(:pot_de_miel)
    links = params[:news][:links_attributes].values
    same  = links.map {|l| l["title"] }.reject(&:blank?).group_by(&:to_s).map {|_,v| v.size }.max.to_i
    render nothing: true if honeypot.present? || same >= 3
  end

  def find_news
    @news = News.find(params[:id])
    enforce_view_permission(@news)
    path = news_path(@news, format: params[:format])
    redirect_to path, status: 301 if request.path != path
  end

  def marked_as_read
    current_account.read(@news.node) unless params[:format] == "md"
  end

end
