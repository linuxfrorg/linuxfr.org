# encoding: UTF-8
class Admin::PagesController < AdminController
  before_filter :find_page, :only => [:edit, :update, :destroy]
  after_filter :expire_cache, :only => [:create, :update]

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
  end

  def update
    @page.attributes = params[:page]
    if @page.save
      redirect_to admin_pages_url, :notice => 'Page mise à jour.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette page"
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to admin_pages_url, :notice => 'Page supprimée'
  end

protected

  def find_page
    @page = Page.find_by_slug(params[:id])
  end

  def expire_cache
    expire_fragment "fragments/layouts/friends_and_links"
    expire_action :controller => '/static', :action => :show, :id => @page
  end
end
