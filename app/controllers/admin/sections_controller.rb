# encoding: UTF-8
class Admin::SectionsController < AdminController
  before_action :find_section, :only => [:edit, :update, :destroy]

  def index
    @sections = Section.all
  end

  def new
    @section = Section.new
  end

  def create
    @section = Section.new(params[:section])
    if @section.save
      redirect_to admin_sections_url, :notice => 'Nouvelle section créée.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette section"
      render :new
    end
  end

  def edit
  end

  def update
    @section.attributes = params[:section]
    if @section.save
      redirect_to admin_sections_url, :notice => 'Section mise à jour.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette section"
      render :edit
    end
  end

  def destroy
    @section.archive
    redirect_to admin_sections_url, :notice => 'Section supprimée'
  end

protected

  def find_section
    @section = Section.find(params[:id])
  end

end
