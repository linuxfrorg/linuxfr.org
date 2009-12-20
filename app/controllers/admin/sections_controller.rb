class Admin::SectionsController < AdminController

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
    @section = Section.find(params[:id])
  end

  def update
    @section = Section.find(params[:id])
    @section.attributes = params[:section]
    if @section.save
      redirect_to admin_sections_url, :notice => 'Section mise à jour.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette section"
      render :edit
    end
  end

  def destroy
    @section = Section.find(params[:id])
    @section.delete
    redirect_to admin_sections_url, :notice => 'Section supprimée'
  end

end
