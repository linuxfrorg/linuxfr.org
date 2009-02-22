class WikiPagesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

  def index
    @main_page  = WikiPage.find_by_title("MainPage")
    @wiki_pages = WikiPage.sorted # TODO only public ones?
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @wiki_page = WikiPage.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @wiki_page && @wiki_page.readable_by?(current_user)
  end

  def new
    @preview_mode = false
    @wiki_page = WikiPage.new
  end

  def create
    @wiki_page = WikiPage.new
    @wiki_page.attributes = params[:wiki_page]
    @wiki_page.committer  = current_user
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @wiki_page.save
      @wiki_page.node = Node.create(:user_id => current_user.id)
      flash[:success] = "Nouvelle page de wiki créée"
      redirect_to wiki_pages_url
    else
      render :new
    end
  end

  def edit
    @wiki_page = WikiPage.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @wiki_page && @wiki_page.editable_by?(current_user)
  end

  def update
    @wiki_page = WikiPage.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @wiki_page && @wiki_page.editable_by?(current_user)
    @wiki_page.attributes = params[:wiki_page]
    @wiki_page.committer  = current_user
    if @wiki_page.save
      flash[:success] = "Modification enregistrée"
      redirect_to @wiki_page
    else
      render :edit
    end
  end

  def destroy
    @wiki_page = WikiPage.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @wiki_page && @wiki_page.deletable_by?(current_user)
    @wiki_page.node.destroy # FIXME
    @wiki_page.mark_as_deleted
    flash[:success] = "Page de wiki supprimée"
    redirect_to wiki_pages_url
  end

  def show_diff
    @wiki_page = WikiPage.find(params[:wiki_page_id])
    raise ActiveRecord::RecordNotFound unless @wiki_page && @wiki_page.readable_by?(current_user)
    @version = @wiki_page.version(params[:sha])
  end

end
