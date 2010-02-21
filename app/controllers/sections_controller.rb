class SectionsController < ApplicationController

  def index
    @sections = Section.published
  end

  def show
    @order   = params[:order] || 'created_at'
    @section = Section.find(params[:id])
    @news    = @section.news.published.joins(:node).order("nodes.#{@order} DESC").paginate(:page => params[:page], :per_page => 10)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

end
