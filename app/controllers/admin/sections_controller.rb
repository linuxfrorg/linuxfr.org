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
      flash[:notice] = 'Nouvelle section créée.'
      redirect_to admin_sections_url
    else
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
      flash[:notice] = 'Section mise à jour.'
      redirect_to admin_sections_url
    else
      render :edit
    end
  end

  def destroy
    @section = Section.find(params[:id])
    @section.delete
    flash[:notice] = 'Section supprimée'
    redirect_to admin_sections_url
  end

end
