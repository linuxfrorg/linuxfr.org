class SectionsController < ApplicationController

  def index
    @sections = Section.published
  end

  def show
    @section = Section.find(params[:id])
    # TODO show news in this section
  end

end
