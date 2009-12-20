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
      redirect_to admin_pages_url, :notice => 'Nouvelle page créée.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette page"
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
      redirect_to admin_pages_url, :notice => 'Page mise à jour.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette page"
      render :edit
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    redirect_to admin_pages_url, :notice => 'Page supprimée'
  end

end
