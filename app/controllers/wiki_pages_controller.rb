class WikiPagesController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show, :revision, :changes]
  before_filter :load_wiki_page, :only => [:edit, :update, :destroy]
  after_filter  :marked_as_read, :only => [:show]

  def index
    respond_to do |wants|
      wants.html { redirect_to WikiPage.home_page }
      wants.atom { @wiki_pages = WikiPage.sorted }
    end
  end

  def show
    begin
      @wiki_page = WikiPage.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      new
      @wiki_page.title = params[:id].titleize
      render :new and return
    end
    redirect_to @wiki_page, :status => 301 if !@wiki_page.friendly_id_status.best?
  end

  def new
    @wiki_page = WikiPage.new
    enforce_create_permission(@wiki_page)
  end

  def create
    @wiki_page = WikiPage.new
    @wiki_page.title = params[:wiki_page][:title]
    @wiki_page.user_id = current_user.id
    @wiki_page.attributes = params[:wiki_page]
    enforce_create_permission(@wiki_page)
    if !preview_mode && @wiki_page.save
      redirect_to @wiki_page, :notice => "Nouvelle page de wiki créée"
    else
      @wiki_page.node = Node.new
      render :new
    end
  end

  def edit
    @wiki_page.wiki_body = @wiki_page.versions.last.body
    enforce_update_permission(@wiki_page)
  end

  def update
    enforce_update_permission(@wiki_page)
    @wiki_page.attributes = params[:wiki_page]
    @wiki_page.user_id = current_user.id
    if !preview_mode && @wiki_page.save
      redirect_to @wiki_page, :notice => "Modification enregistrée"
    else
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@wiki_page)
    @wiki_page.mark_as_deleted
    redirect_to WikiPage.home_page, :notice => "Page de wiki supprimée"
  end

  def revision
    @wiki_page = WikiPage.find(params[:wiki_page_id])
    enforce_view_permission(@wiki_page)
    @version = @wiki_page.versions.find_by_version!(params[:revision])
    previous = @version.higher_item
    @was     = previous ? previous.body : ''
  end

  def changes
    @versions = WikiVersion.order("created_at DESC").joins(:wiki_pages).paginate(:page => params[:page], :per_page => 30)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

protected

  def marked_as_read
    current_user.read(@wiki_page.node) if current_user && @wiki_page.node
  end

  def load_wiki_page
    @wiki_page = WikiPage.find(params[:id])
  end

end
