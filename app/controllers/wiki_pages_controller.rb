# encoding: UTF-8
class WikiPagesController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show, :revision, :changes, :pages]
  before_filter :load_wiki_page, :only => [:edit, :update, :destroy, :revision]
  after_filter  :marked_as_read, :only => [:show], :if => :account_signed_in?
  after_filter  :expire_cache, :only => [:create, :update, :destroy]
  caches_page   :index,   :if => Proc.new { |c| c.request.format.atom? && !c.request.ssl? }
  caches_page   :changes, :if => Proc.new { |c| c.request.format.atom? && !c.request.ssl? }

  def index
    respond_to do |wants|
      wants.html { redirect_to WikiPage.home_page }
      wants.atom { @wiki_pages = WikiPage.sorted }
    end
  end

  def show
    @wiki_page = WikiPage.find(params[:id])
    enforce_view_permission(@wiki_page)
    redirect_to @wiki_page, :status => 301 if !@wiki_page.friendly_id_status.best?
  rescue ActiveRecord::RecordNotFound
    if current_account
      redirect_to new_wiki_page_url(:title => params[:id].titleize)
    else
      render :not_found
    end
  end

  def new
    @wiki_page = WikiPage.new
    @wiki_page.title = params[:title]
    enforce_create_permission(@wiki_page)
  end

  def create
    @wiki_page = WikiPage.new
    @wiki_page.title = params[:wiki_page][:title]
    @wiki_page.user_id = current_account.user_id
    @wiki_page.attributes = params[:wiki_page]
    enforce_create_permission(@wiki_page)
    if !preview_mode && @wiki_page.save
      redirect_to @wiki_page, :notice => "Nouvelle page de wiki créée"
    else
      @wiki_page.node = Node.new
      @wiki_page.valid?
      render :new
    end
  end

  def edit
    @wiki_page.wiki_body = @wiki_page.versions.first.body
    enforce_update_permission(@wiki_page)
  end

  def update
    enforce_update_permission(@wiki_page)
    @wiki_page.attributes = params[:wiki_page]
    @wiki_page.user_id = current_account.user_id
    if !preview_mode && @wiki_page.save
      redirect_to @wiki_page, :notice => "Modification enregistrée"
    else
      flash.now[:alert] = "Impossible d'enregistrer cette page de wiki" if @wiki_page.invalid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@wiki_page)
    @wiki_page.mark_as_deleted
    redirect_to WikiPage.home_page, :notice => "Page de wiki supprimée"
  end

  def revision
    enforce_view_permission(@wiki_page)
    @version = @wiki_page.versions.find_by_version!(params[:revision])
    previous = @version.higher_item
    @was     = previous ? previous.body : ''
  end

  def changes
    @versions = WikiVersion.order("created_at DESC").joins(:wiki_page).page(params[:page])
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def pages
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
    @nodes = Node.public_listing(WikiPage, @order).page(params[:page])
  end

protected

  def marked_as_read
    current_account.read(@wiki_page.node) if @wiki_page.try(:node)
  end

  def load_wiki_page
    @wiki_page = WikiPage.find(params[:id])
  end

  def expire_cache
    return if @wiki_page.new_record?
    expire_page :action => :index,   :format => :atom
    expire_page :action => :changes, :format => :atom
  end
end
