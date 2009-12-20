class WikiPagesController < ApplicationController
  before_filter :user_required, :except => [:index, :show, :revision, :changes]
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
    raise ActiveRecord::RecordNotFound unless @wiki_page && @wiki_page.readable_by?(current_user)
    redirect_to @wiki_page, :status => 301 if @wiki_page.has_better_id?
  end

  def new
    @wiki_page = WikiPage.new
  end

  def create
    @wiki_page = WikiPage.new
    @wiki_page.title = params[:wiki_page][:title]
    @wiki_page.user_id = current_user.id
    @wiki_page.attributes = params[:wiki_page]
    if !preview_mode && @wiki_page.save
      @wiki_page.create_node(:user_id => current_user.id, :cc_licensed => true)
      redirect_to @wiki_page, :notice => "Nouvelle page de wiki créée"
    else
      @wiki_page.node = Node.new
      flash.now[:alert] = "Impossible d'enregistrer cette page de wiki"
      render :new
    end
  end

  def edit
    @wiki_page = WikiPage.find(params[:id])
    @wiki_page.wiki_body = @wiki_page.versions.last.body
    raise ActiveRecord::RecordNotFound unless @wiki_page && @wiki_page.editable_by?(current_user)
  end

  def update
    @wiki_page = WikiPage.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @wiki_page && @wiki_page.editable_by?(current_user)
    @wiki_page.attributes = params[:wiki_page]
    @wiki_page.user_id = current_user.id
    if !preview_mode && @wiki_page.save
      redirect_to @wiki_page, :notice => "Modification enregistrée"
    else
      flash.now[:alert] = "Impossible d'enregistrer cette page de wiki"
      render :edit
    end
  end

  def destroy
    @wiki_page = WikiPage.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @wiki_page && @wiki_page.deletable_by?(current_user)
    @wiki_page.mark_as_deleted
    redirect_to WikiPage.home_page, :notice => "Page de wiki supprimée"
  end

  def revision
    @wiki_page = WikiPage.find(params[:wiki_page_id])
    raise ActiveRecord::RecordNotFound unless @wiki_page && @wiki_page.readable_by?(current_user)
    @version = @wiki_page.versions.find_by_version!(params[:revision])
    previous = @version.higher_item
    @was     = previous ? previous.body : ''
  end

  def changes
    @versions = WikiVersion.paginate(:page => params[:page], :per_page => 30, :order => "created_at DESC", :joins => :wiki_page)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

protected

  def marked_as_read
    current_user.read(@wiki_page.node) if current_user && @wiki_page.node
  end

end
