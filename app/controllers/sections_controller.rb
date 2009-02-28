class SectionsController < ApplicationController

  def index
    @sections = Section.published
  end

  def show
    @section = Section.find(params[:id])
    @news    = @section.news.published.sorted.paginate(:page => params[:page], :per_page => 10)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

end
