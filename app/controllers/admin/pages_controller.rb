class Admin::PagesController < AdminController

  def index
    @pages = Page.all
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = 'Nouvelle page créée.'
      redirect_to admin_pages_url
    else
      render :new
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    @page.attributes = params[:page]
    if @page.save
      flash[:notice] = 'Page mise à jour.'
      redirect_to admin_pages_url
    else
      render :edit
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    flash[:notice] = 'Page supprimée'
    redirect_to admin_pages_url
  end

end
