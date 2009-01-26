class SectionsController < ApplicationController
  # TODO move new/edit/delete to an admin controller

  def index
    @sections = Section.find(:all)
  end

  def show
    @section = Section.find(params[:id])
    # TODO show news in this section
  end

  def new
    @section = Section.new
  end

  def create
    @section = Section.new(params[:section])
    if @section.save
      flash[:notice] = 'Nouvelle section créée.'
      redirect_to @section
    else
      render :action => :new
    end
  end

  def edit
    @section = Section.find(params[:id])
  end

  def update
    @section = Section.find(params[:id])
    if @section.update_attributes(params[:section])
      flash[:notice] = 'Section mise à jour.'
      redirect_to @section
    else
      render :action => :edit
    end
  end

  def destroy
    @section = Section.find(params[:id])
    @section.delete
    redirect_to sections_url
  end
end
