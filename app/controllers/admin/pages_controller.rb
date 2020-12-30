# encoding: UTF-8
class Admin::PagesController < AdminController
  before_action :find_page, only: [:edit, :update, :destroy]

  def index
    @pages = Page.all
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      Board.amr_notification("La page #{@page.title} #{admin_pages_url} a été créée par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_pages_url, notice: 'Nouvelle page créée.'
    else
      flash.now[:alert] = "Impossible d’enregistrer cette page"
      render :new
    end
  end

  def edit
  end

  def update
    @page.attributes = params[:page]
    if @page.save
      Board.amr_notification("La page #{@page.title} #{admin_pages_url} a été mise à jour par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_pages_url, notice: 'Page mise à jour.'
    else
      flash.now[:alert] = "Impossible d’enregistrer cette page"
      render :edit
    end
  end

  def destroy
    Board.amr_notification("La page #{@page.title} #{admin_pages_url} a été supprimée par #{current_user.name} #{user_url(current_user)}")
    @page.destroy
    redirect_to admin_pages_url, notice: 'Page supprimée'
  end

protected

  def find_page
    @page = Page.find_by(slug: params[:id])
  end
end
